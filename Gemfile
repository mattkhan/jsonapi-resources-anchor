source "https://rubygems.org"

ruby "3.3.10"

gemspec

gem "jsonapi-resources",
  "0.11.0.beta2",
  git: "https://github.com/cerebris/jsonapi-resources",
  branch: "v0-11-dev",
  ref: "d3c094b"

# # The original asset pipeline for Rails [https://github.com/rails/sprockets-rails]
gem "sprockets-rails"

# Use postgresql as the database for Active Record
gem "pg", "~> 1.5"

# Use the Puma web server [https://github.com/puma/puma]
gem "puma", ">= 5.0"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: [:windows, :jruby]

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: [:mri, :windows]
  gem "rbs", "~> 3.10.0"
end

group :development do
  gem "rubocop", "~> 1.76", require: false
  gem "rubocop-ast", require: false
  gem "rubocop-performance", require: false
  gem "rubocop-rails", require: false
  gem "rubocop-rspec", require: false
  gem "rubocop-shopify", "~> 2.16", ">= 2.16.0", require: false
end
