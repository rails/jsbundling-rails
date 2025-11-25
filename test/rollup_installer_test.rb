require "test_helper"
require_relative "shared_installer_tests"

class RollupInstallerTest < ActiveSupport::TestCase
  include RailsAppHelpers
  include SharedInstallerTests

  test "rollup installer" do
    with_new_rails_app do
      out, _err = run_installer

      File.read("Procfile.dev").tap do |procfile|
        assert_match "js: npm run build -- --watch", procfile
      end

      assert_match "STUBBED gem install foreman", out

      assert File.exist?("rollup.config.js")

      assert_match %r{STUBBED npm install .* rollup}, out
      assert_match %r{STUBBED npm (?:set-script build |pkg set scripts.build=)rollup .*rollup.config.js}, out
      assert_match "STUBBED npm run build", out
    end
  end

  private
    def run_installer
      stub_bins("gem", "npm")
      run_command("bin/rails", "javascript:install:rollup")
    end
end
