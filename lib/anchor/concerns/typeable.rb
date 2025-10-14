module Anchor
  module Typeable
    extend ActiveSupport::Concern

    included do
      def object(...) = Anchor::Types::Object.new(...)
      def property(...) = Anchor::Types::Property.new(...)
      def maybe(...) = Anchor::Types::Maybe.new(...)
      def array(...) = Anchor::Types::Array.new(...)
      def union(...) = Anchor::Types::Union.new(...)
      def literal(...) = Anchor::Types::Literal.new(...)
      def literals(values) = union(values.map { |value| literal(value) })
      def reference(...) = Anchor::Types::Reference.new(...)
      def references(names) = union(names.map { |name| reference(name) })
      def record(value_type = Anchor::Types::Unknown) = Anchor::Types::Record.new(value_type)

      def boolean = Anchor::Types::Boolean
      def null = Anchor::Types::Null
      def unknown = Anchor::Types::Unknown
      def string = Anchor::Types::String
      def float = Anchor::Types::Float
      def integer = Anchor::Types::Integer
      def big_decimal = Anchor::Types::BigDecimal
    end
  end
end
