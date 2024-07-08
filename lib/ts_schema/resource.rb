module TSSchema
  class Resource < JSONAPI::Resource
    abstract

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

      # @return [String]
      def to_ts_type_string
        properties = [ts_schema_id_property] + [ts_schema_type_property] + ts_schema_attributes_properties + Array.wrap(ts_schema_relationships_property)
        "export type #{schema_name} = " + Types.type_string(Types::Object.new(properties)) + ";"
      end

      private

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

      # @return [Array<TSSchema::Types::Property>]
      def ts_schema_attributes_properties
        _attributes.except(:id).map do |attr, options|
          type = @_ts_schema_attributes[attr] if @_ts_schema_attributes.key?(attr)
          type ||= begin
            attr_name = options[:delegate] || attr
            column = _model_class.try(:columns_hash).try(:[], attr_name.to_s)
            column ? Types::SQL.from(column) : Types::Unknown
          end

          Types::Property.new(attr, type)
        end
      end

      # @return [TSSchema::Types::Property, NilClass]
      def ts_schema_relationships_property
        ts_schema_relationships_properties.then do |properties|
          break if properties.blank?
          Types::Property.new(:relationships, Types::Object.new(properties))
        end
      end

      # @return [Array<TSSchema::Types::Property>]
      def ts_schema_relationships_properties
        _relationships.map do |name, rel|
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
        end
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
