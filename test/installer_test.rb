require "test_helper"

class InstallerTest < ActiveSupport::TestCase
  include RailsAppHelpers

  test "installer" do
    with_new_rails_app do
      out, _err = run_command("bin/rails", "javascript:install:shared")

      assert_equal 0, File.size("app/assets/builds/.keep")
      assert_match "/app/assets/builds/*\n!/app/assets/builds/.keep", File.read(".gitignore")
      assert_equal File.read("#{__dir__}/../lib/install/application.js"), File.read("app/javascript/application.js")
      assert_equal File.read("#{__dir__}/../lib/install/package.json"), File.read("package.json")
      assert_equal File.read("#{__dir__}/../lib/install/dev"), File.read("bin/dev")
      assert_equal 0700, File.stat("bin/dev").mode & 0700

      if sprockets?
        assert_match "//= link_tree ../images", File.read("app/assets/config/manifest.js")
        assert_match "//= link_directory ../stylesheets .css", File.read("app/assets/config/manifest.js")
        assert_match "//= link_tree ../builds", File.read("app/assets/config/manifest.js")
      end
    end
  end

  test "installer for webpack" do
    with_new_rails_app do
      out, _err = run_command("bin/rails", "javascript:install:webpack")

      assert_equal File.read("#{__dir__}/../lib/install/Procfile.dev"), File.read("Procfile.dev")
      assert_equal File.read("#{__dir__}/../lib/install/webpack/webpack.config.js"), File.read("webpack.config.js")

      if sprockets?
        assert_match "//= link_tree ../images", File.read("app/assets/config/manifest.js")
        assert_match "//= link_directory ../stylesheets .css", File.read("app/assets/config/manifest.js")
        assert_match "//= link_tree ../builds", File.read("app/assets/config/manifest.js")
      end
    end
  end

  test "installer with .gitignore" do
    with_new_rails_app do
      out, _err = run_command("bin/rails", "javascript:install:webpack")

      assert_match %(/app/assets/builds/*\n!/app/assets/builds/.keep), File.read(".gitignore")
    end
  end

  test "installer with missing .gitignore" do
    with_new_rails_app do
      FileUtils.rm(".gitignore")
      out, _err = run_command("bin/rails", "javascript:install:webpack")

      assert_not File.exist?(".gitignore")
    end
  end

  test "installer with pre-existing layouts/application.html.erb" do
    with_new_rails_app do
      out, _err = run_command("bin/rails", "javascript:install:webpack")

      assert_match %(Add JavaScript include tag in application layout), out
      assert_match %(<%= javascript_include_tag "application", "data-turbo-track": "reload", type: "module" %>), File.read("app/views/layouts/application.html.erb")
    end
  end

  test "installer with missing layouts/application.html.erb" do
    with_new_rails_app do
      FileUtils.rm("app/views/layouts/application.html.erb")
      out, _err = run_command("bin/rails", "javascript:install:webpack")

      assert_match %(Default application.html.erb is missing!), out
      assert_match %(Add <%= javascript_include_tag "application", "data-turbo-track": "reload", type: "module" %> within the <head> tag in your custom layout.), out
    end
  end

  test "installer with pre-existing Procfile" do
    with_new_rails_app do
      File.write("Procfile.dev", "pre: existing\n")
      out, _err = run_command("bin/rails", "javascript:install:webpack")

      assert_equal "pre: existing\njs: yarn build --watch\n", File.read("Procfile.dev")
    end
  end

  private
    def with_new_rails_app(&block)
      super do
        # We can hook into here, for example to override default Rake behavior to stub out lengthy processes
        block.call
      end
    end
end