module Anchor::Inference::JSONAPI::Infer
  class Base
    include Anchor::Typeable

    def initialize(klass)
      @klass = klass
    end

    def self.infer(...) = new(...).infer
    def infer = raise NotImplementedError
  end
end
