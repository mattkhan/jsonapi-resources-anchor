module Anchor
  module CustomLinkable
    extend ActiveSupport::Concern

    included do
      class << self
        # @param type [Anchor::Types]
        def anchor_links_schema(type = nil)
          @anchor_links_schema ||= type
        end
      end
    end
  end
end
