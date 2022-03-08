namespace :javascript do
  desc "Build your JavaScript bundle"
  task :build do
    unless system "npm install && npm run build"
      raise "jsbundling-rails: Command build failed, ensure npm is installed and `npm run build` runs without errors"
    end
  end
end

if Rake::Task.task_defined?("assets:precompile")
  Rake::Task["assets:precompile"].enhance(["javascript:build"])
end

if Rake::Task.task_defined?("test:prepare")
  Rake::Task["test:prepare"].enhance(["javascript:build"])
elsif Rake::Task.task_defined?("db:test:prepare")
  Rake::Task["db:test:prepare"].enhance(["javascript:build"])
end
