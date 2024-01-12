require "test_helper"

class InstallerTest < ActiveSupport::TestCase
  include RailsAppHelpers

  test "installer" do
    with_new_rails_app do
      out, _err = run_command("bin/rails", "javascript:install:webpack")

      assert_equal 0, File.size("app/assets/builds/.keep")
      assert_match "/app/assets/builds/*\n!/app/assets/builds/.keep", File.read(".gitignore")
      assert_equal File.read("#{__dir__}/../lib/install/webpack/webpack.config.js"), File.read("webpack.config.js")
      assert_equal File.read("#{__dir__}/../lib/install/Procfile.dev"), File.read("Procfile.dev")
      assert_equal File.read("#{__dir__}/../lib/install/dev"), File.read("bin/dev")
      assert_equal 0700, File.stat("bin/dev").mode & 0700

      if sprockets?
        assert_match "//= link_tree ../images", File.read("app/assets/config/manifest.js")
        assert_match "//= link_directory ../stylesheets .css", File.read("app/assets/config/manifest.js")
        assert_match "//= link_tree ../builds", File.read("app/assets/config/manifest.js")
      end
    end
  end

  test "installer with missing .gitignore" do
    with_new_rails_app do
      FileUtils.rm(".gitignore")
      out, _err = run_command("bin/rails", "javascript:install:webpack")

      assert_not File.exist?(".gitignore")
    end
  end

  test "installer with pre-existing application.scss" do
    with_new_rails_app do
      File.write("app/assets/stylesheets/application.scss", "// pre-existing")
      out, _err = run_command("bin/rails", "javascript:install:webpack")

      assert_equal "// pre-existing", File.read("app/assets/stylesheets/application.scss")
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