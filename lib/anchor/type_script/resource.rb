module Anchor::TypeScript
  class Resource
    Definition = Data.define(:name, :object)

    delegate :anchor_schema_name, to: :@klass

    def initialize(klass)
      @klass = klass
    end

    def express(...)
      @object = object(...)
      expression = Anchor::TypeScript::Serializer.type_string(@object)
      "export type #{anchor_schema_name} = " + expression + ";"
    end

    def definition(...)
      @object = object(...)
      Definition.new(name: anchor_schema_name, object: @object)
    end

    def object(context: {}, include_all_fields:)
      t = Anchor::Inference::JSONAPI::ReadType.infer(@klass, context:, include_all_fields:)
      return t if t["relationships"].type.properties.count > 0
      return t.omit(["relationships"]) unless Anchor.config.empty_relationship_type

      t.overwrite(Anchor::Types::Object.new([empty_relationships_property]))
    end

    private

    def empty_relationships_property = property("relationships", Anchor.config.empty_relationship_type.call)
    def property(...) = Anchor::Types::Property.new(...)
  end
end
