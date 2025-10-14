module Anchor::Inference::ActiveRecord::Types
  class Serialized < Base
    def wrap(t) = t.untype(names)

    private

    def names
      @klass.attribute_types.filter_map do |name, type|
        name if type.respond_to?(:coder)
      end
    end
  end
end
