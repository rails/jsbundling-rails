# Configure Rails Environment
ENV["RAILS_ENV"] = "test"

require "fileutils"
require "rails"
require "rails/test_help"

module RailsAppHelpers
  def self.included(base)
    base.include ActiveSupport::Testing::Isolation
  end

  private
    def create_new_rails_app(app_dir, *cli_options)
      require "rails/generators/rails/app/app_generator"
      Rails::Generators::AppGenerator.start([app_dir, "--skip-bundle", "--skip-bootsnap", "--quiet", cli_options].flatten)

      Dir.chdir(app_dir) do
        gemfile = File.read("Gemfile")

        gemfile.gsub!(/^gem ["']jsbundling-rails["'].*/, "")
        gemfile << %(gem "jsbundling-rails", path: #{File.expand_path("..", __dir__).inspect}\n)

        if Rails::VERSION::PRE == "alpha"
          gemfile.gsub!(/^gem ["']rails["'].*/, "")
          gemfile << %(gem "rails", path: #{Gem.loaded_specs["rails"].full_gem_path.inspect}\n)
        end

        File.write("Gemfile", gemfile)

        run_command("bundle", "install")
      end
    end

    def with_new_rails_app(*cli_options, &block)
      require "digest/sha1"
      variant = [RUBY_VERSION, Gem.loaded_specs["rails"].full_gem_path, cli_options.flatten.sort]
      app_name = "app_#{Digest::SHA1.hexdigest(variant.to_s)}"
      cache_dir = "#{__dir__}/../tmp"
      FileUtils.mkdir_p(cache_dir)

      Dir.mktmpdir do |tmpdir|
        if Dir.exist?("#{cache_dir}/#{app_name}")
          FileUtils.cp_r("#{cache_dir}/#{app_name}", tmpdir)
        else
          create_new_rails_app("#{tmpdir}/#{app_name}", *cli_options)
          FileUtils.cp_r("#{tmpdir}/#{app_name}", cache_dir) # Cache app for future runs.
        end

        Dir.chdir("#{tmpdir}/#{app_name}", &block)
      end
    end

    def stub_bins(*names)
      names.each do |name|
        File.write("bin/#{name}", <<~BASH)
          #!/usr/bin/env bash
          echo STUBBED #{name} "$@"
        BASH

        FileUtils.chmod(0755, "bin/#{name}")
      end
    end

    def run_command(*command)
      Bundler.with_unbundled_env do
        env = { "PATH" => "bin:#{ENV["PATH"]}" }
        capture_subprocess_io { system(env, *command, exception: true) }
      end
    end
end
