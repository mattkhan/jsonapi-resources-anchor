module Anchor
  class SchemaGenerator
    def initialize(register:, context:, include_all_fields:)
      @register = register
      @context = context
      @include_all_fields = include_all_fields
    end

    def self.call(...)
      new(...).call
    end

    def call
      raise NotImplementedError
    end
  end
end

