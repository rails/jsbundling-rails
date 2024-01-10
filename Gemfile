source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

# Specify your gem's dependencies in importmap-rails.gemspec.
gemspec

rails_version = ENV["RAILS_VERSION"] || "7.1.2"
gem "propshaft"
gem "puma"
gem "rails", "~> #{rails_version}"

group :test do
  gem "capybara"
  gem "minitest"
  gem "selenium-webdriver"
end
