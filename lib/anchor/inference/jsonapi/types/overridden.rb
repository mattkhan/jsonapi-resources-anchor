module Anchor::Inference::JSONAPI::Types
  class Overridden < Base
    def wrap(t) = t.untype(names)

    private

    def names
      count = @klass.anchor_method_added_count || Hash.new(0)
      @klass._attributes.keys.filter_map do |name|
        name.to_s if count[name.to_sym] > 1
      end
    end
  end
end
