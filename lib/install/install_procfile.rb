if Rails.root.join("Procfile.dev").exist?
  append_to_file "Procfile.dev", "js: #{Jsbundling::PackageManager.build_command(with_watch:true)}\n"
else
  say "Add default Procfile.dev"
  copy_file "#{__dir__}/Procfile.dev", "Procfile.dev"
  gsub_file "Procfile.dev", 'js: #{npm_build_watch}', "js: #{Jsbundling::PackageManager.build_command(with_watch:true)}"

  say "Ensure foreman is installed"
  run "gem install foreman"
end
