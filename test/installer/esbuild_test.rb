require "json"
require "test_helper"

class EsbuildInstallerTest < ActiveSupport::TestCase
  include RailsAppHelpers

  test "installer for esbuild" do
    with_new_rails_app do
      _out, _err = run_command("bin/rails", "javascript:install:esbuild")

      assert_equal File.read("#{__dir__}/../../lib/install/Procfile.dev"), File.read("Procfile.dev")

      JSON.parse(File.read("package.json")).tap do |package|
        assert_not_nil package["dependencies"]["esbuild"]
        assert_match "esbuild", package["scripts"]["build"]
      end

      if sprockets?
        assert_match "//= link_tree ../builds", File.read("app/assets/config/manifest.js")
      end
    end
  end

  test "installer with pre-existing Procfile" do
    with_new_rails_app do
      File.write("Procfile.dev", "pre: existing\n")
      _out, _err = run_command("bin/rails", "javascript:install:esbuild")

      assert_equal <<~YAML, File.read("Procfile.dev")
        pre: existing
        js: yarn build --watch
      YAML
    end
  end
end
