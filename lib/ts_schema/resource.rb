module TSSchema
  class Resource < JSONAPI::Resource
    abstract
    include TypeSerializable
  end
end
