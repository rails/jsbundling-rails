require "test_helper"
require_relative "shared_installer_tests"

class BunInstallerTest < ActiveSupport::TestCase
  include RailsAppHelpers
  include SharedInstallerTests

  private
    def run_installer
      stub_bins("gem")
      run_command("bin/rails", "javascript:install:bun")
    end
end
