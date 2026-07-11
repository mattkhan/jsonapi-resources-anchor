module Anchor
  module Types
    class Walk
      def self.call(...) = new(...).call

      def initialize(type)
        @type = type
      end
    end
  end
end
