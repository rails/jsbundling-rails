apply "#{__dir__}/../install.rb"
apply "#{__dir__}/../install_procfile.rb"

say "Install rollup with config"
copy_file "#{__dir__}/rollup.config.js", "rollup.config.js"
run Jsbundling::PackageManager.add_command("rollup @rollup/plugin-node-resolve", dev: true)

say "Add build script"
build_script = "rollup -c --bundleConfigAsCjs rollup.config.js"

case `npx -v`.to_f
when 7.1...8.0
  run %(npm set-script build "#{build_script}")
  run Jsbundling::PackageManager.build_command
when (8.0..)
  run %(npm pkg set scripts.build="#{build_script}")
  run Jsbundling::PackageManager.build_command
else
  say %(Add "scripts": { "build": "#{build_script}" } to your package.json), :green
end
