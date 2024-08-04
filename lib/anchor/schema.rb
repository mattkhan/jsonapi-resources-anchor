module Anchor
  class Schema
    class << self
      Register = Struct.new(:resources, :enums, keyword_init: true)

      def resource(resource)
        @resources ||= []
        @resources.push(resource)
      end

      def enum(enum)
        @enums ||= []
        @enums.push(enum)
      end

      def generate(context: {}, adapter: :type_script, include_all_fields: false)
        adapter = case adapter
          when :type_script then Anchor::TypeScript::SchemaGenerator
          when :json_schema then Anchor::JSONSchema::SchemaGenerator
          else adapter
        end

        adapter.call(
          register: Register.new(resources: @resources || [], enums: @enums || []),
          context:,
          include_all_fields:
        )
      end
    end
  end
end
