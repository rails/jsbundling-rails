namespace :javascript do
  desc "Build your JavaScript bundle"
  task :build do
    system "yarn install && yarn build"
  end
end

Rake::Task["assets:precompile"].enhance(["javascript:build"])

if Rake::Task.task_defined?("test:prepare")
  Rake::Task["test:prepare"].enhance(["javascript:build"])
elsif Rake::Task.task_defined?("db:test:prepare")
  Rake::Task["db:test:prepare"].enhance(["javascript:build"])
end
