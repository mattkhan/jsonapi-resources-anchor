module Anchor::JSONSchema
  class Resource
    delegate :anchor_schema_name, to: :@klass

    def initialize(klass)
      @klass = klass
    end

    def express(context: {}, include_all_fields:)
      t = Anchor::Inference::JSONAPI::ReadType.infer(@klass, context:, include_all_fields:).omit(["meta", "links"])
      t["relationships"].type.properties.count > 0 ? t : t.omit(["relationships"])
    end
  end
end
