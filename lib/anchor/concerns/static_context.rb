module Anchor
  module StaticContext
    extend ActiveSupport::Concern

    included do
      class << self
        def anchor_fetchable_fields(context)
          fields
        end
      end
    end
  end
end
