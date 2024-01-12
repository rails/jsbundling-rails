source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

# Specify your gem's dependencies in jsbundling-rails.gemspec.
gemspec

rails_version = ENV["RAILS_VERSION"] || "6.1.0"
gem "rails", "~> #{rails_version}"
gem "appraisal"
gem "debug", ">= 1.0.0"

group :test do
  gem "turbo-rails"
  gem "stimulus-rails"

  gem "byebug"

  gem "rexml"
  gem "capybara"
  gem "selenium-webdriver"
  gem "webdrivers"
end
