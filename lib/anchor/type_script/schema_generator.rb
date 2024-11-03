module Anchor::TypeScript
  class SchemaGenerator < Anchor::SchemaGenerator
    def call
      maybe_type = "type Maybe<T> = T | null;"

      enum_expressions = enums.map(&:express)
      type_expressions = resources.map do |r|
        r.express(
          context: @context,
          include_all_fields: @include_all_fields,
          exclude_fields: @exclude_fields.nil? ? [] : @exclude_fields[r.anchor_schema_name.to_sym],
        )
      end

      ([maybe_type] + enum_expressions + type_expressions).join("\n\n") + "\n"
    end

    private

    def resources
      @resources ||= @register.resources.map { |r| Anchor::TypeScript::Resource.new(r) }
    end

    def enums
      @enums ||= @register.enums.map { |e| Anchor::TypeScript::Types::Enum.new(e) }
    end
  end

  class MultifileSchemaGenerator < Anchor::SchemaGenerator
    def initialize(**opts)
      super(**opts.except(:manually_editable))
      @manually_editable = opts[:manually_editable] || false
    end

    def call
      [shared_file] + resource_files
    end

    private

    def shared_file
      maybe_type = "export type Maybe<T> = T | null;"

      enum_expressions = enums.map(&:express)
      content = ([maybe_type] + enum_expressions).join("\n\n") + "\n"
      { name: "shared.ts", content: }
    end

    def resource_files
      resources.map do |r|
        definition = r.definition(
          context: @context,
          include_all_fields: @include_all_fields,
          exclude_fields: @exclude_fields.nil? ? [] : @exclude_fields[r.anchor_schema_name.to_sym],
        )

        file_structure = ::Anchor::TypeScript::FileStructure.new(definition)
        content = file_structure.to_code(manually_editable: @manually_editable)
        name = file_structure.name
        { name:, content: }
      end
    end

    def resources
      @resources ||= @register.resources.map { |r| Anchor::TypeScript::Resource.new(r) }
    end

    def enums
      @enums ||= @register.enums.map { |e| Anchor::TypeScript::Types::Enum.new(e) }
    end
  end
end
