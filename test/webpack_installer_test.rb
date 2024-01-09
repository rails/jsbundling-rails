require "test_helper"
require_relative "shared_installer_tests"

class WebpackInstallerTest < ActiveSupport::TestCase
  include RailsAppHelpers
  include SharedInstallerTests

  test "webpack installer" do
    with_new_rails_app do
      out, _err = run_installer

      File.read("Procfile.dev").tap do |procfile|
        assert_match "js: yarn build --watch", procfile
      end

      assert_match "STUBBED gem install foreman", out

      assert File.exist?("webpack.config.js")

      assert_match "STUBBED yarn add webpack", out
      assert_match %r{STUBBED npm (?:set-script build |pkg set scripts.build=)webpack --config webpack.config.js}, out
      assert_match "STUBBED yarn build", out
    end
  end

  private
    def run_installer
      stub_bins("gem", "yarn", "npm")
      run_command("bin/rails", "javascript:install:webpack")
    end
end
