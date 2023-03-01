namespace :javascript do
  desc "Install JavaScript dependencies"
  task :install do
    unless system "yarn install"
      raise "jsbundling-rails: Command install failed, ensure yarn is installed"
    end
  end

  desc "Build your JavaScript bundle"
  build_task = task :build do
    unless system "yarn build"
      raise "jsbundling-rails: Command build failed, ensure `yarn build` runs without errors"
    end
  end
  build_task.prereqs << :install unless ENV["SKIP_YARN_INSTALL"]
end

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
