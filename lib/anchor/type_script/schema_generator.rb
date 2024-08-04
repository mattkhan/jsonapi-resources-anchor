module Anchor::TypeScript
  class SchemaGenerator
    attr_reader :context, :include_all_fields

    def initialize(register:, context:, include_all_fields:)
      @resources = register.resources.map { |r| Anchor::TypeScript::Resource.new(r) }
      @enums = register.enums.map { |e| Anchor::TypeScript::Types::Enum.new(e) }
      @context = context
      @include_all_fields = include_all_fields
    end

    def self.call(...)
      new(...).call
    end

    def call
      maybe_type = "type Maybe<T> = T | null;"

      enums = @enums.map(&:express)
      types = @resources.map { |r| r.express(context:, include_all_fields:) }

      ([maybe_type] + enums + types).join("\n\n") + "\n"
    end
  end
end
