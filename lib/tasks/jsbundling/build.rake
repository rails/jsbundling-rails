namespace :javascript do
  desc "Build your JavaScript bundle"
  task :build do
    unless system "yarn build"
      raise "jsbundling-rails: Command build failed, ensure yarn is installed and `yarn build` runs without errors"
    end
  end
end

Rake::Task["assets:precompile"].enhance(["javascript:build"])

if Rake::Task.task_defined?("test:prepare")
  Rake::Task["test:prepare"].enhance(["javascript:build"])
elsif Rake::Task.task_defined?("db:test:prepare")
  Rake::Task["db:test:prepare"].enhance(["javascript:build"])
end

if Rake::Task.task_defined?("yarn:install")
  Rake::Task["javascript:build"].enhance(["yarn:install"])
end
