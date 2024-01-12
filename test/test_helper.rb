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
    def sprockets?
      Gem.loaded_specs.key?("sprockets-rails")
    end

    def propshaft?
      Gem.loaded_specs.key?("propshaft")
    end

    def asset_pipeline_option
      if Rails::VERSION::MAJOR >= 7
        if propshaft?
          "--asset-pipeline=propshaft"
        elsif sprockets?
          "--asset-pipeline=sprockets"
        end
      end
    end

    def create_new_rails_app(app_dir)
      require "rails/generators/rails/app/app_generator"
      Rails::Generators::AppGenerator.start([app_dir, *asset_pipeline_option, "--skip-bundle", "--skip-bootsnap", "--quiet"])

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

    def with_new_rails_app(&block)
      require "digest/sha1"
      variant = [RUBY_VERSION, Gem.loaded_specs["rails"].full_gem_path, asset_pipeline_option]
      app_name = "app_#{Digest::SHA1.hexdigest(variant.to_s)}"

      Dir.mktmpdir do |tmpdir|
        create_new_rails_app("#{tmpdir}/#{app_name}")
        Dir.chdir("#{tmpdir}/#{app_name}", &block)
      end
    end

    def run_command(*command)
      Bundler.with_unbundled_env do
        capture_subprocess_io { system(*command, exception: true) }
      end
    end
end