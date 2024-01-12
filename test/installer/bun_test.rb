require "json"
require "test_helper"

class BunInstallerTest < ActiveSupport::TestCase
  include RailsAppHelpers

  test "installer for bun" do
    with_new_rails_app do
      _out, _err = run_command("bin/rails", "javascript:install:bun")

      assert_match "js: bun run build --watch", File.read("Procfile.dev")

      assert_equal File.read("#{__dir__}/../../lib/install/bun/bun.config.js"), File.read("bun.config.js")

      JSON.parse(File.read("package.json")).tap do |package|
        assert_equal("bun bun.config.js", package["scripts"]["build"])
      end

      if sprockets?
        assert_match "//= link_tree ../builds", File.read("app/assets/config/manifest.js")
      end
    end
  end

  test "installer with pre-existing Procfile" do
    with_new_rails_app do
      File.write("Procfile.dev", "pre: existing\n")
      _out, _err = run_command("bin/rails", "javascript:install:bun")

      assert_equal <<~YAML, File.read("Procfile.dev")
        pre: existing
        js: bun run build --watch
      YAML
    end
  end
end
