require "json"
require "test_helper"

class WebpackInstallerTest < ActiveSupport::TestCase
  include RailsAppHelpers

  test "installer for webpack" do
    with_new_rails_app do
      _out, _err = run_command("bin/rails", "javascript:install:webpack")

      assert_equal File.read("#{__dir__}/../../lib/install/Procfile.dev"), File.read("Procfile.dev")
      assert_equal File.read("#{__dir__}/../../lib/install/webpack/webpack.config.js"), File.read("webpack.config.js")

      JSON.parse(File.read("package.json")).tap do |package|
        assert_not_nil package["dependencies"]["webpack"]
        assert_not_nil package["dependencies"]["webpack-cli"]
        assert_equal "webpack --config webpack.config.js", package["scripts"]["build"]
      end

      if sprockets?
        assert_match "//= link_tree ../images", File.read("app/assets/config/manifest.js")
        assert_match "//= link_directory ../stylesheets .css", File.read("app/assets/config/manifest.js")
        assert_match "//= link_tree ../builds", File.read("app/assets/config/manifest.js")
      end
    end
  end

  test "installer with pre-existing Procfile" do
    with_new_rails_app do
      File.write("Procfile.dev", "pre: existing\n")
      _out, _err = run_command("bin/rails", "javascript:install:webpack")

      assert_equal "pre: existing\njs: yarn build --watch\n", File.read("Procfile.dev")
    end
  end
end
