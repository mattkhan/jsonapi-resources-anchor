module Anchor
  class Schema
    class << self
      def resource(resource)
        @resources ||= []
        @resources.push(resource)
      end

      def enum(enum)
        @enums ||= []
        @enums.push(enum)
      end

      def generate(context: {}, adapter: :type_script, include_all_fields: true)
        adapter = case adapter
          when :type_script then Anchor::TypeScript::SchemaGenerator
          when :json_schema then Anchor::JSONSchema::SchemaGenerator
          else adapter
        end

        adapter.call(
          resources: @resources || [],
          enums: @enums || [],
          context:,
          include_all_fields:
        )
      end
    end
  end
end
