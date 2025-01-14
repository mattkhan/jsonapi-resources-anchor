module Anchor
  module SchemaSerializable
    extend ActiveSupport::Concern
    include Anchor::TypeInferable
    include Anchor::StaticContext
    include Anchor::Annotatable
    include Anchor::CustomLinkable
    include Anchor::CustomMeta
  end
end
