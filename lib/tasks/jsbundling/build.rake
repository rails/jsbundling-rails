namespace :javascript do
  desc "Install JavaScript dependencies"
  task :install do
    command = Jsbundling::Tasks.install_command
    unless system(command)
      raise "jsbundling-rails: Command install failed, ensure #{command.split.first} is installed"
    end
  end

  desc "Build your JavaScript bundle"
  build_task = task :build do
    command = Jsbundling::Tasks.build_command
    unless system(command)
      raise "jsbundling-rails: Command build failed, ensure `#{command}` runs without errors"
    end
  end

  build_task.prereqs << :install unless ENV["SKIP_YARN_INSTALL"] || ENV["SKIP_BUN_INSTALL"]
end

module Jsbundling
  module Tasks
    extend self

    def install_command
      return "bun install" if File.exist?('bun.lockb') || (tool_exists?('bun') && !File.exist?('yarn.lock'))
      return "yarn install" if File.exist?('yarn.lock') || tool_exists?('yarn')
      raise "jsbundling-rails: No suitable tool found for installing JavaScript dependencies"
    end

    def build_command
      return "bun run build" if File.exist?('bun.lockb') || (tool_exists?('bun') && !File.exist?('yarn.lock'))
      return "yarn build" if File.exist?('yarn.lock') || tool_exists?('yarn')
      raise "jsbundling-rails: No suitable tool found for building JavaScript"
    end

    def tool_exists?(tool)
      system "command -v #{tool} > /dev/null"
    end
  end
end

unless ENV["SKIP_JS_BUILD"]
  if Rake::Task.task_defined?("assets:precompile")
    Rake::Task["assets:precompile"].enhance(["javascript:build"])
  end

  if Rake::Task.task_defined?("test:prepare")
    Rake::Task["test:prepare"].enhance(["javascript:build"])
  elsif Rake::Task.task_defined?("spec:prepare")
    Rake::Task["spec:prepare"].enhance(["javascript:build"])
  elsif Rake::Task.task_defined?("db:test:prepare")
    Rake::Task["db:test:prepare"].enhance(["javascript:build"])
  end
end
