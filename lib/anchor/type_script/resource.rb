module Anchor::TypeScript
  class Resource < Anchor::Resource
    def express(context: {}, include_all_fields:)
      included_fields = schema_fetchable_fields(context:, include_all_fields:)

      properties = [id_property, type_property] +
        Array.wrap(anchor_attributes_properties(included_fields:)) +
        Array.wrap(anchor_relationships_property(included_fields:))

      "export type #{anchor_schema_name} = " + Anchor::TypeScript::Serializer.type_string(Anchor::Types::Object.new(properties)) + ";"
    end
  end
end
