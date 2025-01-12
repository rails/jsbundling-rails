require "test_helper"
require_relative "shared_installer_tests"

class RspackInstallerTest < ActiveSupport::TestCase
  include RailsAppHelpers
  include SharedInstallerTests

  test "rspack installer" do
    with_new_rails_app do
      out, _err = run_installer

      File.read("Procfile.dev").tap do |procfile|
        assert_match "js: yarn build --watch", procfile
      end

      assert_match "STUBBED gem install foreman", out

      assert File.exist?("rspack.config.js")

      assert_match %r{STUBBED yarn add.* @rspack}, out
      assert_match %r{STUBBED npm (?:set-script build |pkg set scripts.build=)rspack --config rspack.config.js}, out
      assert_match "STUBBED yarn build", out
    end
  end

  private
    def run_installer
      stub_bins("gem", "yarn", "npm")
      run_command("bin/rails", "javascript:install:rspack")
    end
end
