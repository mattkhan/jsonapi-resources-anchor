module Anchor::Inference::JSONAPI::Infer
  class AnchorDef < Base
    delegate :resource_key_type, :_type, :_attributes, :_relationships, to: :@klass

    def initialize(klass)
      super(klass)
      @anchor_attributes = klass.try(:anchor_attributes) || {}
      @anchor_relationships = klass.try(:anchor_relationships) || {}
      @anchor_attributes_descriptions = klass.try(:anchor_attributes_descriptions) || {}
      @anchor_relationships_descriptions = klass.try(:anchor_relationships_descriptions) || {}
      @anchor_links_schema = klass.try(:anchor_links_schema) || nil
      @anchor_meta_schema = klass.try(:anchor_meta_schema) || nil
    end

    def infer
      object([
        id,
        type,
        *attributes,
        *relationships,
        meta,
        links,
      ].compact)
    end

    private

    def attributes
      _attributes.except(:id).filter_map do |attr, _|
        next unless @anchor_attributes.key?(attr)

        property(
          attr.to_s,
          @anchor_attributes[attr],
          false,
          @anchor_attributes_descriptions[attr],
        )
      end
    end

    def relationships
      _relationships.filter_map do |name, rel|
        next if @anchor_relationships.exclude?(name)

        anchor_relationship = @anchor_relationships[name]
        polymorphic = anchor_relationship.resources.present?

        base_type = if polymorphic
          references(anchor_relationship.resources.map(&:anchor_schema_name))
        else
          reference(anchor_relationship.resource.anchor_schema_name)
        end

        if rel.is_a?(::JSONAPI::Relationship::ToMany)
          null_elements = anchor_relationship.null_elements.present?
          base_type |= null if null_elements
          base_type = array(base_type)
        end

        type = anchor_relationship.null.present? ? maybe(base_type) : base_type
        property(name.to_s, type, false, @anchor_relationships_descriptions[name])
      end
    end

    def id
      # TODO: resource_key_type can also return a proc
      res_key_type = case resource_key_type
      when :integer then integer
      else string
      end
      property("id", res_key_type)
    end

    def type = property("type", literal(_type))

    def links
      return unless @anchor_links_schema
      property("links", @anchor_links_schema)
    end

    def meta
      return unless @anchor_meta_schema
      property("meta", @anchor_meta_schema)
    end
  end
end
