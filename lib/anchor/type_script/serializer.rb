module Anchor::TypeScript
  class Serializer
    class << self 
      def type_string(type, depth=1)
        case type
        when Anchor::Types::String.singleton_class then "string"
        when Anchor::Types::BigDecimal.singleton_class then "string"
        when Anchor::Types::Float.singleton_class then "number"
        when Anchor::Types::Integer.singleton_class then "number"
        when Anchor::Types::Boolean.singleton_class then "boolean"
        when Anchor::Types::Null.singleton_class then "null"
        when Anchor::Types::Record, Anchor::Types::Record.singleton_class then "Record<string, #{type_string(type.try(:value_type) || Anchor::Types::Unknown)}>"
        when Anchor::Types::Union then type.types.map { |type| type_string(type, depth) }.join(' | ')
        when Anchor::Types::Maybe then "Maybe<#{type_string(type.type, depth)}>"
        when Anchor::Types::Array then "Array<#{type_string(type.type, depth)}>"
        when Anchor::Types::Literal then serialize_literal(type.value)
        when Anchor::Types::Reference then type.name
        when Anchor::Types::Object then serialize_object(type, depth)
        when Anchor::Types::Enum.singleton_class then type.anchor_schema_name
        when Anchor::Types::Unknown.singleton_class then "unknown"
        else raise RuntimeError
        end
      end

      private

      def serialize_literal(value)
        case value
        when ::String, ::Symbol then "\"#{value}\""
        else value.to_s
        end
      end

      def serialize_object(type, depth)
        properties = type.properties.map { |p| "#{safe_name(p)}: #{type_string(p.type, depth + 1)};" }
        indent = " " * (depth * 2)
        properties = properties.map { |p| p.prepend(indent) }.join("\n")
        ["{", properties, "}".prepend(indent[2..])].join("\n")
      end

      def safe_name(property)
        name = property.name
        name.match?(/[^a-zA-Z0-9_]/) ? "\"#{name}\"" : name.to_s + (property.optional ? "?" : "")
      end
    end
  end
end
