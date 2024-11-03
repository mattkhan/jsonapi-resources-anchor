module Anchor
  class Schema
    class << self
      Register = Struct.new(:resources, :enums, keyword_init: true)

      def register
        Register.new(resources: @resources || [], enums: @enums || [])
      end

      def resource(resource)
        @resources ||= []
        @resources.push(resource)
      end

      def enum(enum)
        @enums ||= []
        @enums.push(enum)
      end

      def generate(context: {}, adapter: :type_script, include_all_fields: false, exclude_fields: nil)
        adapter = case adapter
        when :type_script then Anchor::TypeScript::SchemaGenerator
        when :json_schema then Anchor::JSONSchema::SchemaGenerator
        else adapter
        end

        adapter.call(
          register:,
          context:,
          include_all_fields:,
          exclude_fields:,
        )
      end
    end
  end
end
