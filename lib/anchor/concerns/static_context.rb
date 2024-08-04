module Anchor
  module StaticContext
    extend ActiveSupport::Concern

    included do
      def fetchable_fields
        self.class.fetchable_fields(context)
      end

      class << self
        def fetchable_fields(context)
          fields
        end
      end
    end
  end
end
