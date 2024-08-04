module Anchor::TypeScript
  module Types
    class Enum
      delegate_missing_to :@enum_klass

      def initialize(enum_klass)
        @enum_klass = enum_klass
      end

      # @return [String]
      def express
        ["export enum #{anchor_schema_name} {", named_constants, "}"].join("\n")
      end

      private

      def named_constants
        values.map { |name, value| "  #{name.to_s.camelize} = #{Anchor::TypeScript::Serializer.type_string(value)}," }.join("\n")
      end
    end
  end
end
