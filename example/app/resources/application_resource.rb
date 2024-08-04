class ApplicationResource < JSONAPI::Resource
  abstract
  include Anchor::Annotatable
end
