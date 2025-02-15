module Anchor::TypeScript
  class SchemaGenerator < Anchor::SchemaGenerator
    def initialize(register:, context: {}, include_all_fields: false, exclude_fields: nil) # rubocop:disable Lint/MissingSuper
      @register = register
      @context = context
      @include_all_fields = include_all_fields
      @exclude_fields = exclude_fields
    end

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
end
