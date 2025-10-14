module Anchor
  module Inference
    module JSONAPI
      class ReadType
        include Anchor::Typeable

        attr_reader :t

        delegate :convert_case, to: Anchor::Types

        def initialize(klass, context: {}, include_all_fields: false)
          @klass = klass
          @t = Anchor::Inference::JSONAPI::Infer::Resource.infer(klass)
          @context = context
          @include_all_fields = include_all_fields
        end

        def self.infer(...) = new(...).infer

        def infer
          id +
            type +
            readable(attributes).convert_case +
            object([property(
              "relationships",
              readable(relationships.nullable_to_optional).convert_case,
            )]) +
            meta +
            links
        end

        def readable(t)
          Anchor::Inference::JSONAPI::Types::Readable.new(
            @klass, context: @context, include_all_fields: @include_all_fields
          ).wrap(t)
        end

        def id = t.pick(["id"])
        def type = t.pick(["type"])
        def attributes = t.pick(@klass._attributes.except(:id).keys.map(&:to_s))
        def relationships = t.pick(@klass._relationships.keys.map(&:to_s))
        def meta = t["meta"].type.is_a?(unknown.singleton_class) ? t.pick([]) : t.pick(["meta"])
        def links = t["links"].type.is_a?(unknown.singleton_class) ? t.pick([]) : t.pick(["links"])
      end
    end
  end
end
