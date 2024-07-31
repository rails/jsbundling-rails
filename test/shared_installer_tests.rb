require "json"

module SharedInstallerTests
  extend ActiveSupport::Concern

  included do
    test "basic installation with pre-existing files" do
      with_new_rails_app do
        File.write(".gitignore", "# pre-existing\n", mode: "a+")
        File.write("package.json", %({ "name": "pre-existing" }\n))
        File.write("Procfile.dev", "pre: existing\n", mode: "a+")
        FileUtils.mkdir_p("app/javascript")
        File.write("app/javascript/application.js", "// pre-existing\n", mode: "a+")

        run_installer

        File.read("bin/dev").tap do |bin_dev|
          assert_equal File.read("#{__dir__}/../lib/install/dev"), bin_dev
          assert_equal 0700, File.stat("bin/dev").mode & 0700
        end

        assert_equal 0, File.size("app/assets/builds/.keep")

        File.read("app/views/layouts/application.html.erb").tap do |layout|
          assert_match %(<%= javascript_include_tag "application", "data-turbo-track": "reload", type: "module" %>), layout[%r{<head.*</head>}m]
        end

        File.read(".gitignore").tap do |gitignore|
          assert_match "# pre-existing", gitignore
          assert_match "/app/assets/builds/*\n!/app/assets/builds/.keep", gitignore
          assert_match "/node_modules", gitignore
        end

        JSON.load_file("package.json").tap do |package_json|
          assert_equal "pre-existing", package_json["name"]
        end

        File.read("Procfile.dev").tap do |procfile|
          assert_match "pre: existing", procfile
          assert_match %r{^js: }, procfile
        end

        File.read("app/javascript/application.js").tap do |js_entrypoint|
          assert_match "// pre-existing", js_entrypoint
        end
      end
    end

    test "basic installation without pre-existing files" do
      with_new_rails_app do
        FileUtils.rm("app/views/layouts/application.html.erb")
        FileUtils.rm(".gitignore")
        FileUtils.rm_rf("package.json")
        FileUtils.rm_rf("Procfile.dev")
        FileUtils.rm_rf("app/javascript/application.js")

        out, _err = run_installer

        assert_not File.exist?("app/views/layouts/application.html.erb")
        assert_match "Add <%= javascript_include_tag", out

        assert_not File.exist?(".gitignore")

        JSON.load_file("package.json").tap do |package_json|
          assert_includes package_json, "name"
        end

        File.read("Procfile.dev").tap do |procfile|
          assert_match %r{^js: }, procfile
        end

        assert File.exist?("app/javascript/application.js")
      end
    end

    test "basic installation with Sprockets" do
      with_new_rails_app(*("--asset-pipeline=sprockets" if Rails::VERSION::MAJOR >= 7)) do
        File.write("app/assets/config/manifest.js", "// pre-existing\n", mode: "a+")

        run_installer

        File.read("app/assets/config/manifest.js").tap do |sprockets_manifest|
          assert_match "// pre-existing", sprockets_manifest
          assert_match "//= link_tree ../builds", sprockets_manifest
        end
      end
    end

    if Rails::VERSION::MAJOR == 7
      test "basic installation with Propshaft" do
        with_new_rails_app("--asset-pipeline=propshaft") do
          run_installer

          assert_not File.exist?("app/assets/config/manifest.js")
        end
      end
    end
  end
end
