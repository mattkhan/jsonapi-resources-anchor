module Anchor
  class Resource
    delegate_missing_to :@resource_klass
    attr_reader :resource_klass

    # @param [JSONAPI::Resource] Must include Anchor::TypeInferable
    def initialize(resource_klass)
      @resource_klass = resource_klass
      @anchor_attributes = resource_klass.try(:anchor_attributes) || {} # optional method from Anchor::Annotatable
      @anchor_relationships = resource_klass.try(:anchor_relationships) || {} # optional method from Anchor::Annotatable
      @anchor_attributes_descriptions = resource_klass.try(:anchor_attributes_descriptions) || {} # optional method from Anchor::Annotatable
      @anchor_relationships_descriptions = resource_klass.try(:anchor_relationships_descriptions) || {} # optional method from Anchor::Annotatable
      @anchor_method_added_count = resource_klass.anchor_method_added_count || Hash.new(0)
    end

    def express(...)
      raise NotImplementedError
    end

    private

    delegate :convert_case, to: Anchor::Types

    def schema_fetchable_fields(context:, include_all_fields:)
      return fields unless statically_determinable_fetchable_fields? && !include_all_fields
      @resource_klass.fetchable_fields(context)
    end

    def statically_determinable_fetchable_fields?
      @resource_klass.singleton_class.method_defined?(:fetchable_fields)
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
        next unless included_fields.include?(attr.to_sym)
        description = @anchor_attributes_descriptions[attr]
        next Anchor::Types::Property.new(convert_case(attr), @anchor_attributes[attr], false, description) if @anchor_attributes.key?(attr)

        type = begin
          model_method = options[:delegate] || attr
          resource_method = attr

          model_method_defined = _model_class.try(:method_defined?, model_method.to_sym)
          resource_method_defined = @anchor_method_added_count[resource_method.to_sym] > 1
          method_defined = model_method_defined || resource_method_defined

          column = !method_defined && _model_class.try(:columns_hash).try(:[], model_method.to_s)
          if column
            type = Anchor::Types::Inference::ActiveRecord::SQL.from(column)
            check_presence = type.is_a?(Anchor::Types::Maybe) && Anchor.config.use_active_record_presence
            if check_presence && _model_class.validators_on(model_method).any? { |v| v.is_a?(ActiveRecord::Validations::PresenceValidator) }
              type.type
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

    # @param included_fields [Array<Symbol>]
    # @return [Array<Anchor::Types::Property>]
    def anchor_relationships_properties(included_fields:)
      _relationships.filter_map do |name, rel|
        next unless included_fields.include?(name.to_sym)
        description = @anchor_relationships_descriptions[name]
        relationship_type = relationship_type_for(rel, rel.resource_klass, name) if @anchor_relationships.exclude?(name)

        relationship_type ||= begin
          anchor_relationship = @anchor_relationships[name]

          type = if (resources = anchor_relationship.resources)
            references = resources.map { |resource_klass| Anchor::Types::Reference.new(resource_klass.anchor_schema_name) }
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
    # @return [Anchor::Types::Reference, Anchor::Types::Array<Anchor::Types::Reference>, Anchor::Types::Maybe<Anchor::Types::Reference>]
    def relationship_type_for(rel, resource_klass, name)
      ref = Anchor::Types::Reference.new(resource_klass.anchor_schema_name)
      reflection = _model_class.try(:reflections).try(:[], name.to_s)
      wrapper = reflection ? Anchor::Types::Inference::ActiveRecord.wrapper_from_reflection(reflection) : Anchor::Types::Inference::JSONAPI.wrapper_from_relationship(rel)
      wrapper.call(ref)
    end
  end
end
