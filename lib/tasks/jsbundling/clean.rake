namespace :js do
  desc "Remove JavaScript builds"
  task :clean do
    rm_rf Dir["app/assets/builds/[^.]*.js"], verbose: false
  end
end

Rake::Task["assets:clean"].enhance(["js:clean"])
