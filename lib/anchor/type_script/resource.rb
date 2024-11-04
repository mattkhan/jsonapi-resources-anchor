module Anchor::TypeScript
  class Resource < Anchor::Resource
    def express(context: {}, include_all_fields:, exclude_fields:)
      included_fields = schema_fetchable_fields(context:, include_all_fields:)
      included_fields -= exclude_fields if exclude_fields

      properties = [id_property, type_property] +
        Array.wrap(anchor_attributes_properties(included_fields:)) +
        Array.wrap(anchor_relationships_property(included_fields:)) + [anchor_links_property].compact

      expression = Anchor::TypeScript::Serializer.type_string(Anchor::Types::Object.new(properties))
      "export type #{anchor_schema_name} = " + expression + ";"
    end
  end
end
