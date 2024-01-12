require "json"
require "test_helper"

class RollupInstallerTest < ActiveSupport::TestCase
  include RailsAppHelpers

  test "installer for rollup" do
    with_new_rails_app do
      _out, _err = run_command("bin/rails", "javascript:install:rollup")

      assert_equal File.read("#{__dir__}/../../lib/install/Procfile.dev"), File.read("Procfile.dev")
      assert_equal File.read("#{__dir__}/../../lib/install/rollup/rollup.config.js"), File.read("rollup.config.js")

      JSON.parse(File.read("package.json")).tap do |package|
        assert_not_nil package["dependencies"]["rollup"]
        assert_not_nil package["dependencies"]["@rollup/plugin-node-resolve"]
        assert_equal "rollup -c --bundleConfigAsCjs rollup.config.js", package["scripts"]["build"]
      end

      if sprockets?
        assert_match "//= link_tree ../builds", File.read("app/assets/config/manifest.js")
      end
    end
  end

  test "installer with pre-existing Procfile" do
    with_new_rails_app do
      File.write("Procfile.dev", "pre: existing\n")
      _out, _err = run_command("bin/rails", "javascript:install:rollup")

      assert_equal <<~YAML, File.read("Procfile.dev")
        pre: existing
        js: yarn build --watch
      YAML
    end
  end
end
