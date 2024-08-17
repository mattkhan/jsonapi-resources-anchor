class ApplicationResource < JSONAPI::Resource
  abstract
  include Anchor::SchemaSerializable
end
