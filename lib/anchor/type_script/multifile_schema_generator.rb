module Anchor::TypeScript
  class MultifileSchemaGenerator < Anchor::SchemaGenerator
    Result = Struct.new(:name, :text, :type, keyword_init: true)

    module FileType
      RESOURCE = "resource"
      UTIL = "util"
    end

    def initialize(register:, context: {}, include_all_fields: false, exclude_fields: nil, manually_editable: true) # rubocop:disable Lint/MissingSuper
      @register = register
      @context = context
      @include_all_fields = include_all_fields
      @exclude_fields = exclude_fields
      @manually_editable = manually_editable
    end

    def call
      [shared_file] + resource_files
    end

    private

    def shared_file
      maybe_type = "export type Maybe<T> = T | null;"

      enum_expressions = enums.map(&:express)
      text = ([maybe_type] + enum_expressions).join("\n\n") + "\n"
      Result.new(name: "shared.ts", text:, type: FileType::UTIL)
    end

    def resource_files
      resources.map do |r|
        definition = r.definition(
          context: @context,
          include_all_fields: @include_all_fields,
          exclude_fields: @exclude_fields.nil? ? [] : @exclude_fields[r.anchor_schema_name.to_sym],
        )

        file_structure = ::Anchor::TypeScript::FileStructure.new(definition)
        text = file_structure.to_code(manually_editable: @manually_editable)
        name = file_structure.name
        Result.new(name:, text:, type: FileType::RESOURCE)
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
