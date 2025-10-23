require_relative "lib/anchor/version"

Gem::Specification.new do |s|
  s.name        = "jsonapi-resources-anchor"
  s.version     = Anchor::VERSION
  s.summary     = "jsonapi-resources type annotation, inference, and schema/docs generation"
  s.authors     = ["Matt"]
  s.license     = "MIT"
  s.metadata = {
    "changelog_uri" => "https://github.com/mattkhan/jsonapi-resources-anchor/blob/main/CHANGELOG.md",
    "documentation_uri" => "https://jsonapi-resources-anchor.up.railway.app/docs",
    "source_code_uri" => "https://github.com/mattkhan/jsonapi-resources-anchor",
    "github_repo" => "ssh://github.com/mattkhan/jsonapi-resources-anchor",
  }

  s.files = Dir.glob("lib/**/*").reject { |f| File.directory?(f) }

  s.required_ruby_version = ">= 3.1"
  s.add_dependency("jsonapi-resources", "~> 0.1")
  s.add_dependency("rails", ">= 7.0", "< 8.1")
  s.add_development_dependency("rspec-rails", "~> 7.0")
  s.add_development_dependency("yard")
  s.add_development_dependency("yard-activesupport-concern")
end
