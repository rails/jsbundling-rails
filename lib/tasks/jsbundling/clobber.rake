namespace :javascript do
  desc "Remove JavaScript builds"
  task :clobber do
    rm_rf Dir["app/assets/builds/[^.]*.js"], verbose: false
  end
end
