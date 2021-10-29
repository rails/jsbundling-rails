namespace :js do
  desc "Build your JavaScript bundle"
  task :build do
    unless system "yarn install && yarn build"
      raise "jsbundling-rails: Command build failed, ensure yarn is installed and `yarn build` runs without errors"
    end
  end
end

Rake::Task["assets:precompile"].enhance(["js:build"])

if Rake::Task.task_defined?("test:prepare")
  Rake::Task["test:prepare"].enhance(["js:build"])
elsif Rake::Task.task_defined?("db:test:prepare")
  Rake::Task["db:test:prepare"].enhance(["js:build"])
end
