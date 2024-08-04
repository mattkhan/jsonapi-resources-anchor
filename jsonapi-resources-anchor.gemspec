Gem::Specification.new do |s|
  s.name        = "jsonapi-resources-anchor"
  s.version     = "0.0.0.pre"
  s.summary     = "jsonapi-resources type annotation, inference, and schema/docs generation"
  s.authors     = ["Matt"]
  s.files       = Dir.glob("lib/**/*").reject { |f| File.directory?(f) }
  s.license     = "MIT"

  s.required_ruby_version = ">= 3.0"
  s.add_dependency "jsonapi-resources", "~> 0.1"
  s.add_development_dependency "yard"
end
