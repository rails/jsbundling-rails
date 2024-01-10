# frozen_string_literal: true

require "active_support/testing/strict_warnings"

ENV["RAILS_ENV"] = "test"

require "bundler/setup"

require "rails"
require "action_controller/railtie"
require "action_view/railtie"

class TestApp < Rails::Application
  config.load_defaults("#{Rails::VERSION::MAJOR}.#{Rails::VERSION::MINOR}")
  config.eager_load = false
end

Rails.application.initialize!
