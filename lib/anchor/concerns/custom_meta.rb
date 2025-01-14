module Anchor
  module CustomMeta
    extend ActiveSupport::Concern

    included do
      class << self
        # @param type [Anchor::Types]
        def anchor_meta_schema(type = nil)
          @anchor_meta_schema ||= type
        end
      end
    end
  end
end
