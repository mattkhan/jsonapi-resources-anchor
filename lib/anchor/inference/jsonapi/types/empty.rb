module Anchor::Inference::JSONAPI::Types
  class Empty < Base
    def initialize(klass = nil)
      super(klass)
    end

    def wrap(t) = Anchor::Types::Object.new([])
  end
end
