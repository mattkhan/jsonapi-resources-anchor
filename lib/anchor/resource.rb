module Anchor
  class Resource
    delegate_missing_to :@resource_klass
    attr_reader :resource_klass

    # resource_klass#anchor_attributes, #anchor_relationships, #anchor_attributes_descriptions,
    # #anchor_relationships_descriptions are optional methods from Anchor::Annotatable.
    # @param [JSONAPI::Resource] Must include Anchor::TypeInferable
    def initialize(resource_klass)
      @resource_klass = resource_klass
      @anchor_attributes = resource_klass.try(:anchor_attributes) || {}
      @anchor_relationships = resource_klass.try(:anchor_relationships) || {}
      @anchor_attributes_descriptions = resource_klass.try(:anchor_attributes_descriptions) || {}
      @anchor_relationships_descriptions = resource_klass.try(:anchor_relationships_descriptions) || {}
      @anchor_method_added_count = resource_klass.anchor_method_added_count || Hash.new(0)
      @anchor_links_schema = resource_klass.try(:anchor_links_schema) || nil
      @anchor_meta_schema = resource_klass.try(:anchor_meta_schema) || nil
    end

    def express(...)
      raise NotImplementedError
    end

    private

    delegate :convert_case, to: Anchor::Types

    def schema_fetchable_fields(context:, include_all_fields:)
      return fields unless statically_determinable_fetchable_fields? && !include_all_fields
      @resource_klass.anchor_fetchable_fields(context)
    end

    def statically_determinable_fetchable_fields?
      @resource_klass.singleton_class.method_defined?(:anchor_fetchable_fields)
    end

    # @return [Anchor::Types::Property]
    def id_property
      # TODO: resource_key_type can also return a proc
      res_key_type = case resource_key_type
      when :integer then Anchor::Types::Integer
      else Anchor::Types::String
      end

      Anchor::Types::Property.new(:id, res_key_type)
    end

    # @return [Anchor::Types::Property]
    def type_property
      Anchor::Types::Property.new(:type, Anchor::Types::Literal.new(_type))
    end

    # @param included_fields [Array<Symbol>]
    # @return [Array<Anchor::Types::Property>]
    def anchor_attributes_properties(included_fields:)
      _attributes.except(:id).filter_map do |attr, options|
        next if included_fields.exclude?(attr.to_sym)
        description = @anchor_attributes_descriptions[attr]
        next Anchor::Types::Property.new(
          convert_case(attr),
          @anchor_attributes[attr],
          false,
          description,
        ) if @anchor_attributes.key?(attr)

        type = begin
          model_method = options[:delegate] || attr
          resource_method = attr

          model_method_defined = _model_class.try(
            :method_defined?,
            model_method.to_sym,
          ) && !_model_class.instance_method(model_method.to_sym)
            .owner.is_a?(ActiveRecord::AttributeMethods::GeneratedAttributeMethods)
          resource_method_defined = @anchor_method_added_count[resource_method.to_sym] > 1
          serializer_defined = (_model_class.try(:attribute_types) || {})[model_method.to_s].respond_to?(:coder)
          method_defined = model_method_defined || resource_method_defined || serializer_defined

          enum = Anchor.config.infer_ar_enums && !method_defined && _model_class.try(:defined_enums).try(:[], model_method.to_s)
          column = !method_defined && _model_class.try(:columns_hash).try(:[], model_method.to_s)

          if column
            type = Anchor::Types::Inference::ActiveRecord::SQL.from(column)

            if enum
              enum_type = Anchor::Types::Union.new(enum.map { |_key, val| Anchor::Types::Literal.new(val) })
              type = type.is_a?(Anchor::Types::Maybe) ? Anchor::Types::Maybe.new(enum_type) : enum_type
            end

            unless description
              description = column.comment if Anchor.config.use_active_record_comment
              if description && !Anchor.config.ar_comment_to_string.nil?
                description = Anchor.config.ar_comment_to_string.call(description)
              end
            end
            check_presence = type.is_a?(Anchor::Types::Maybe) && Anchor.config.use_active_record_validations
            if check_presence && _model_class.validators_on(model_method).any? do |v|
                 if v.is_a?(ActiveRecord::Validations::NumericalityValidator)
                   opts = v.options.with_indifferent_access
                   !(opts[:allow_nil] || opts[:if] || opts[:unless] || opts[:on])
                 elsif v.is_a?(ActiveRecord::Validations::PresenceValidator)
                   opts = v.options.with_indifferent_access
                   !(opts[:if] || opts[:unless] || opts[:on])
                 end
               end
              type.type
            elsif type.is_a?(Anchor::Types::Maybe) && Anchor.config.infer_default_as_non_null
              column.default.present? || column.default_function.present? && column.instance_variable_get(:@generated).blank? ? type.type : type
            else
              type
            end
          else
            Anchor::Types::Unknown
          end
        end

        Anchor::Types::Property.new(convert_case(attr), type, false, description)
      end
    end

    # @param included_fields [Array<Symbol>]
    # @return [Anchor::Types::Property, NilClass]
    def anchor_relationships_property(included_fields:)
      anchor_relationships_properties(included_fields:).then do |properties|
        break if properties.blank?
        Anchor::Types::Property.new(:relationships, Anchor::Types::Object.new(properties))
      end
    end

    def anchor_links_property
      if @anchor_links_schema
        Anchor::Types::Property.new("links", @anchor_links_schema, false)
      end
    end

    def anchor_meta_property
      if @anchor_meta_schema
        Anchor::Types::Property.new("meta", @anchor_meta_schema, false)
      end
    end

    # @param included_fields [Array<Symbol>]
    # @return [Array<Anchor::Types::Property>]
    def anchor_relationships_properties(included_fields:)
      _relationships.filter_map do |name, rel|
        next if included_fields.exclude?(name.to_sym)
        description = @anchor_relationships_descriptions[name]
        relationship_type = relationship_type_for(rel, rel.resource_klass, name) if @anchor_relationships.exclude?(name)

        relationship_type ||= begin
          anchor_relationship = @anchor_relationships[name]

          type = if (resources = anchor_relationship.resources)
            references = resources.map do |resource_klass|
              Anchor::Types::Reference.new(resource_klass.anchor_schema_name)
            end
            null_type = Array.wrap(anchor_relationship.null_elements.presence && Anchor::Types::Null)
            Anchor::Types::Union.new(references + null_type)
          else
            Anchor::Types::Reference.new(anchor_relationship.resource.anchor_schema_name)
          end

          type = Anchor::Types::Inference::JSONAPI.wrapper_from_relationship(rel).call(type)
          anchor_relationship.null.present? ? Anchor::Types::Maybe.new(type) : type
        end

        use_optional = Anchor.config.infer_nullable_relationships_as_optional
        if use_optional && relationship_type.is_a?(Anchor::Types::Maybe)
          Anchor::Types::Property.new(convert_case(name), relationship_type.type, true, description)
        else
          Anchor::Types::Property.new(convert_case(name), relationship_type, false, description)
        end
      end
    end

    # @param rel [Relationship]
    # @param resource_klass [Anchor::Resource]
    # @param name [String, Symbol]
    # @return [Anchor::Types::Reference, Anchor::Types::Array<Anchor::Types::Reference>, Anchor::Types::Maybe<Anchor::Types::Reference>, Anchor::Types::Union<Anchor::Types::Reference>]
    def relationship_type_for(rel, resource_klass, name)
      rel_type = if rel.polymorphic? && rel.respond_to?(:polymorphic_types) # 0.11.0.beta2
        resource_klasses = rel.polymorphic_types.map { |t| resource_klass_for(t) }
        Anchor::Types::Union.new(resource_klasses.map { |rk| Anchor::Types::Reference.new(rk.anchor_schema_name) })
      elsif rel.polymorphic? && rel.class.respond_to?(:polymorphic_types) # TODO: < 0.11.0.beta2
        resource_klasses = rel.class.polymorphic_types.map { |t| resource_klass_for(t) }
        Anchor::Types::Union.new(resource_klasses.map { |rk| Anchor::Types::Reference.new(rk.anchor_schema_name) })
      end

      rel_type ||= Anchor::Types::Reference.new(resource_klass.anchor_schema_name)
      model_relationship_name = (rel.options[:relation_name] || name).to_s
      reflection = _model_class.try(:reflections).try(:[], model_relationship_name)
      wrapper = if reflection
        Anchor::Types::Inference::ActiveRecord.wrapper_from_reflection(reflection)
      else
        Anchor::Types::Inference::JSONAPI.wrapper_from_relationship(rel)
      end

      wrapper.call(rel_type)
    end
  end
end
