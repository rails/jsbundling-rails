apply "#{__dir__}/../install.rb"
apply "#{__dir__}/../install_procfile.rb"

say "Install rollup with config"
copy_file "#{__dir__}/rollup.config.js", "rollup.config.js"
run "yarn add --dev rollup @rollup/plugin-node-resolve"

say "Add build script"
build_script = "rollup -c --bundleConfigAsCjs rollup.config.js"

case `npx -v`.to_f
when 7.1...8.0
  run %(npm set-script build "#{build_script}")
  run %(yarn build)
when (8.0..)
  run %(npm pkg set scripts.build="#{build_script}")
  run %(yarn build)
else
  say %(Add "scripts": { "build": "#{build_script}" } to your package.json), :green
end

if (puma_config_path = Rails.root.join("config/puma.rb")).exist?
  say %(Adding plugin to puma.rb)
  insert_into_file puma_config_path, %|\nplugin :yarn if ENV.fetch("RAILS_ENV", "development") == "development"|, after:  "plugin :tmp_restart"
end
