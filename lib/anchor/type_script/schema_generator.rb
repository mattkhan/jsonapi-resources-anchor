module Anchor::TypeScript
  class SchemaGenerator < Anchor::SchemaGenerator
    def call
      maybe_type = "type Maybe<T> = T | null;"

      enum_expressions = enums.map(&:express)
      type_expressions = resources.map { |r| r.express(context: @context, include_all_fields: @include_all_fields) }

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
