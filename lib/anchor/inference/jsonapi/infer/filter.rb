module Anchor::Inference::JSONAPI::Infer
  class Filter < Base
    def infer = object(properties)

    private

    def properties
      filters.map { |name, _opts| property(name.to_s, unknown) }
    end

    def filters = @klass._allowed_filters
  end
end
