require "test_helper"
require_relative "shared_installer_tests"

class BunInstallerTest < ActiveSupport::TestCase
  include RailsAppHelpers
  include SharedInstallerTests

  test "bun installer with pre-existing files" do
    with_new_rails_app do
      File.write(".gitattributes", "# pre-existing\n", mode: "a+")
      File.write("Procfile.dev", "pre: existing\n", mode: "a+")

      run_installer

      File.read(".gitattributes").tap do |gitattributes|
        assert_match "# pre-existing", gitattributes
        assert_match "*.lockb diff=lockb", gitattributes
      end

      File.read("Procfile.dev").tap do |procfile|
        assert_match "pre: existing", procfile
        assert_match "js: bun run build --watch", procfile
      end

      JSON.load_file("package.json").tap do |package_json|
        assert_equal "bun bun.config.js", package_json["scripts"]["build"]
      end
    end
  end

  test "bun installer without pre-existing files" do
    with_new_rails_app do
      FileUtils.rm_rf(".gitattributes")
      FileUtils.rm_rf("Procfile.dev")

      out, _err = run_installer

      File.read(".gitattributes").tap do |gitattributes|
        assert_match "*.lockb diff=lockb", gitattributes
      end

      File.read("Procfile.dev").tap do |procfile|
        assert_match "js: bun run build --watch", procfile
      end

      assert_match "STUBBED gem install foreman", out
    end
  end

  private
    def run_installer
      stub_bins("gem")
      run_command("bin/rails", "javascript:install:bun")
    end
end
