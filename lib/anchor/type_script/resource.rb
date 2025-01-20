module Anchor::TypeScript
  class Resource < Anchor::Resource
    def express(context: {}, include_all_fields:, exclude_fields:)
      included_fields = schema_fetchable_fields(context:, include_all_fields:)
      included_fields -= exclude_fields if exclude_fields

      relationships_property = anchor_relationships_property(included_fields:)
      if relationships_property.nil? && Anchor.config.empty_relationship_type
        relationships_property = Anchor::Types::Property.new(:relationships, Anchor.config.empty_relationship_type.call)
      end

      properties = [id_property, type_property] +
        Array.wrap(anchor_attributes_properties(included_fields:)) +
        Array.wrap(relationships_property) +
        [anchor_meta_property].compact + [anchor_links_property].compact

      expression = Anchor::TypeScript::Serializer.type_string(Anchor::Types::Object.new(properties))
      "export type #{anchor_schema_name} = " + expression + ";"
    end
  end
end
