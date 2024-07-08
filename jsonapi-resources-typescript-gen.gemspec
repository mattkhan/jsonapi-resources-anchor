Gem::Specification.new do |s|
  s.name        = "jsonapi-resources-typescript-gen"
  s.version     = "0.0.0.pre"
  s.summary     = "Generate a TypeScript schema from jsonapi-resources"
  s.authors     = ["Matt"]
  s.files       = ["lib/jsonapi-resources-typescript-gen.rb", "lib/ts_schema/resource.rb", "lib/ts_schema/types.rb", "lib/ts_schema/schema.rb"]
  s.license     = "MIT"

  s.required_ruby_version = ">= 3.0"
  s.add_dependency "jsonapi-resources", "~> 0.1"
  s.add_development_dependency "yard"
end
