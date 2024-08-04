module Anchor::JSONSchema
  class Serializer
    class << self 
      def type_property(type)
        case type
        when Anchor::Types::String.singleton_class then { type: "string" }
        when Anchor::Types::BigDecimal.singleton_class then { type: "string" }
        when Anchor::Types::Float.singleton_class then { type: "number" }
        when Anchor::Types::Integer.singleton_class then { type: "number" }
        when Anchor::Types::Boolean.singleton_class then { type: "boolean" }
        when Anchor::Types::Null.singleton_class then { type: "null" }
        when Anchor::Types::Record, Anchor::Types::Record.singleton_class then { type: "object", additionalProperties: "true" }
        when Anchor::Types::Union then { oneOf: type.types.map { |type| type_property(type) } }
        when Anchor::Types::Maybe then type_property(Anchor::Types::Union.new([type.type, Anchor::Types::Null]))
        when Anchor::Types::Array then { type: "array", items: type_property(type.type) }
        when Anchor::Types::Literal then { enum: [type.value] }
        when Anchor::Types::Reference then { "$ref" => "#/$defs/#{type.name}" }
        when Anchor::Types::Object then serialize_object(type)
        when Anchor::Types::Enum.singleton_class then { enum: type.values.map(&:second) }
        when Anchor::Types::Unknown.singleton_class then {}
        else raise RuntimeError
        end
      end

      private

      def serialize_object(type)
        {
          type: "object",
          properties: type.properties.map { |p| { p.name => type_property(p.type) } }.reduce(&:merge),
          required: type.properties.reject(&:optional).map(&:name),
          additionalProperties: false,
        }
      end
    end
  end
end
