require "test_helper"
require_relative "shared_installer_tests"

class EsbuildInstallerTest < ActiveSupport::TestCase
  include RailsAppHelpers
  include SharedInstallerTests

  test "esbuild installer with yarn by default" do
    with_new_rails_app do
      out, _err = run_installer

      File.read("Procfile.dev").tap do |procfile|
        assert_match "js: yarn build --watch", procfile
      end

      assert_match "STUBBED gem install foreman", out
      assert_match %r{STUBBED yarn add.* esbuild}, out
      assert_match %r{STUBBED npm (?:set-script build |pkg set scripts.build=)esbuild app/javascript/\*\.\*}, out
      assert_match "STUBBED yarn build", out
    end
  end

  test "esbuild installer with yarn.lock exists" do
    with_new_rails_app do
      File.write("package.json", "\n", mode: "a+")
      File.write("yarn.lock", "\n", mode: "a+")

      out, _err = run_installer

      File.read("Procfile.dev").tap do |procfile|
        assert_match "js: yarn build --watch", procfile
      end

      assert_match "STUBBED gem install foreman", out
      assert_match %r{STUBBED yarn add.* esbuild}, out
      assert_match %r{STUBBED npm (?:set-script build |pkg set scripts.build=)esbuild app/javascript/\*\.\*}, out
      assert_match "STUBBED yarn build", out
    end
  end

  test "esbuild installer with npm when package-lock.json exists" do
    with_new_rails_app do
      File.write("package.json", "\n", mode: "a+")
      File.write("package-lock.json", "\n", mode: "a+")

      out, _err = run_installer

      File.read("Procfile.dev").tap do |procfile|
        assert_match "js: npm run build -- --watch", procfile
      end

      assert_match "STUBBED gem install foreman", out
      assert_match %r{STUBBED npm install.* esbuild}, out
      assert_match %r{STUBBED npm (?:set-script build |pkg set scripts.build=)esbuild app/javascript/\*\.\*}, out
      assert_match "STUBBED npm run build", out
    end
  end

  test "esbuild installer with pnpm when pnpm-lock.yaml exists" do
    with_new_rails_app do
      File.write("package.json", "\n", mode: "a+")
      File.write("pnpm-lock.yaml", "\n", mode: "a+")

      out, _err = run_installer

      File.read("Procfile.dev").tap do |procfile|
        assert_match "js: pnpm run build -- --watch", procfile
      end

      assert_match "STUBBED gem install foreman", out
      assert_match %r{STUBBED pnpm add.* esbuild}, out
      assert_match %r{STUBBED npm (?:set-script build |pkg set scripts.build=)esbuild app/javascript/\*\.\*}, out
      assert_match "STUBBED pnpm run build", out
    end
  end

  private
    def run_installer
      stub_bins("gem", "yarn", "npm", "pnpm")
      run_command("bin/rails", "javascript:install:esbuild")
    end
end
