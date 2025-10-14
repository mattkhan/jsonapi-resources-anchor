module Anchor::Inference::JSONAPI::Types
  class Readable < Base
    def initialize(klass, context: {}, include_all_fields: false)
      super(klass)
      @context = context
      @include_all_fields = include_all_fields
    end

    def wrap(t) = t.pick(names.map(&:to_s))

    private

    def names
      return @klass.fields unless statically_determinable_fetchable_fields? && !@include_all_fields
      @klass.anchor_fetchable_fields(@context)
    end

    def statically_determinable_fetchable_fields?
      @klass.singleton_class.method_defined?(:anchor_fetchable_fields)
    end
  end
end
