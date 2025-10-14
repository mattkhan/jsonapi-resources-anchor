module Anchor::Inference::JSONAPI::Infer
  class Shell < Base
    def infer
      object({
        id: unknown,
        type: unknown,
        **attributes.index_with { unknown },
        **relationships.index_with { unknown },
        meta: unknown,
        links: unknown,
      })
    end

    private

    def object(hash)
      props = hash.map { |key, type| property(key.to_s, type) }
      Anchor::Types::Object.new(props)
    end

    def attributes = @klass._attributes.except(:id).keys
    def relationships = @klass._relationships.keys
  end
end
