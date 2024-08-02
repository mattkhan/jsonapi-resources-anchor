module TSSchema
  module TypeSerializable
    extend ActiveSupport::Concern

    included do
      def fetchable_fields
        self.class.fetchable_fields(context)
      end

      class << self
        # @param name [String] The type identifier to be used in the schema.
        # @return [String]
        def schema_name(name = nil)
          @schema_name ||= name || default_schema_name
        end

        # @param name [String, Symbol]
        # @param type_or_options [TSSchema::Types, Hash, NilClass]
        # @param options [Hash]
        def attribute(name, type_or_options = nil, options = {})
          @_ts_schema_attributes ||= {}
          opts = type_or_options.is_a?(Hash) ? type_or_options : options
          type_given = !(type_or_options.is_a?(Hash) || type_or_options.nil?)
          @_ts_schema_attributes[name] = type_or_options if type_given
          super(name, opts)
        end

        # @param name [String, Symbol]
        # @param resource_or_options [TSSchema::Types::Relationship, Hash, NilClass]
        # @param options [Hash]
        def relationship(name, resource_or_options = nil, options = {})
          @_ts_schema_relationships ||= {}
          opts = resource_or_options.is_a?(Hash) ? resource_or_options : options
          resource_given = !(resource_or_options.is_a?(Hash) || resource_or_options.nil?)
          @_ts_schema_relationships[name] = resource_or_options if resource_given
          super(name, opts)
        end

        # @param context [Hash]
        # @return [String]
        def to_ts_type_string(context: {}, include_all_fields:)
          included_fields = context.blank? && include_all_fields ? fields : self.fetchable_fields(context)
          properties = [ts_schema_id_property] + [ts_schema_type_property] + ts_schema_attributes_properties(included_fields:) + Array.wrap(ts_schema_relationships_property(included_fields:))
          "export type #{schema_name} = " + Types.type_string(Types::Object.new(properties)) + ";"
        end

        def fetchable_fields(context)
          fields
        end

        private

        def method_added(method_name)
          @_method_added_count ||= Hash.new(0)
          @_method_added_count[method_name] += 1
        end

        # @return [TSSchema::Types::Property]
        def ts_schema_id_property
          # TODO: resource_key_type can also return a proc
          res_key_type = case resource_key_type
          when :integer then Types::Number
          else Types::String
          end

          Types::Property.new(:id, res_key_type)
        end

        # @return [TSSchema::Types::Property]
        def ts_schema_type_property
          Types::Property.new(:type, Types::Literal.new(_type))
        end

        # @param included_fields [Array<Symbol>]
        # @return [Array<TSSchema::Types::Property>]
        def ts_schema_attributes_properties(included_fields:)
          _attributes.except(:id).filter_map do |attr, options|
            next unless included_fields.include?(attr.to_sym)
            type = @_ts_schema_attributes[attr] if @_ts_schema_attributes.key?(attr)
            type ||= begin
              model_method = options[:delegate] || attr
              resource_method = attr

              model_method_defined = _model_class.method_defined?(model_method.to_sym)
              resource_method_defined = @_method_added_count[resource_method.to_sym] > 1
              method_defined = model_method_defined || resource_method_defined

              column = !method_defined && _model_class.try(:columns_hash).try(:[], model_method.to_s)
              if column
                type = Types::SQL.from(column)
                check_presence = type.is_a?(Types::Maybe) && TSSchema.config.use_active_record_presence
                if check_presence && _model_class.validators_on(model_method).any? { |v| v.is_a?(ActiveRecord::Validations::PresenceValidator) }
                  type.type
                else
                  type
                end
              else
                Types::Unknown
              end
            end

            Types::Property.new(attr, type)
          end.map(&:format_keys!)
        end

        # @param included_fields [Array<Symbol>]
        # @return [TSSchema::Types::Property, NilClass]
        def ts_schema_relationships_property(included_fields:)
          ts_schema_relationships_properties(included_fields:).then do |properties|
            break if properties.blank?
            Types::Property.new(:relationships, Types::Object.new(properties))
          end
        end

        # @param included_fields [Array<Symbol>]
        # @return [Array<TSSchema::Types::Property>]
        def ts_schema_relationships_properties(included_fields:)
          @_ts_schema_relationships ||= {}

          _relationships.filter_map do |name, rel|
            next unless included_fields.include?(name.to_sym)
            relationship_type = relationship_type_for(rel, rel.resource_klass, name) if @_ts_schema_relationships.exclude?(name)

            relationship_type ||= begin
              ts_schema_relationship = @_ts_schema_relationships[name]

              type = if (resources = ts_schema_relationship.resources)
                references = resources.map { |resource_klass| Types::Reference.new(resource_klass.schema_name) }
                null_type = Array.wrap(ts_schema_relationship.null_elements.presence && Types::Null)
                Types::Union.new(references + null_type)
              else
                Types::Reference.new(ts_schema_relationship.resource.schema_name)
              end

              type = Types::JSONAPI.wrapper_from_relationship(rel).call(type)
              ts_schema_relationship.null.present? ? Types::Maybe.new(type) : type
            end

            Types::Property.new(name, relationship_type)
          end.map(&:format_keys!)
        end

        # @param rel [Relationship]
        # @param resource_klass [JSONAPI::Resource]
        # @param name [String, Symbol]
        # @return [TSSchema::Types::Reference, TSSchema::Types::Array<TSSchema::Types::Reference>, TSSchema::Types::Maybe<TSSchema::Types::Reference>]
        def relationship_type_for(rel, resource_klass, name)
          ref = Types::Reference.new(resource_klass.schema_name)
          reflection = _model_class.try(:reflections).try(:[], name.to_s)
          wrapper = reflection ? Types::ActiveRecord.wrapper_from_reflection(reflection) : Types::JSONAPI.wrapper_from_relationship(rel)
          wrapper.call(ref)
        end

        # inspiration from https://github.com/rmosolgo/graphql-ruby/blob/eda9b3d62b9e507787e590f0f179ec9d6956255a/lib/graphql/schema/member/base_dsl_methods.rb?plain=1#L102
        def default_schema_name
          s_name = name.split("::").last
          s_name.end_with?("Resource") ? s_name.sub(/Resource\Z/, "") : s_name
        end
      end
    end
  end
end
