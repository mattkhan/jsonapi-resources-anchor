module Anchor::Inference::JSONAPI::Types
  class Base
    def initialize(klass)
      @klass = klass
    end

    def wrap(t) = raise NotImplementedError
  end
end
