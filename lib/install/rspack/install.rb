apply "#{__dir__}/../install.rb"
apply "#{__dir__}/../install_procfile.rb"

say "Install Rspack with config"
copy_file "#{__dir__}/rspack.config.js", "rspack.config.js"
run "yarn add --dev @rspack/core @rspack/cli"

say "Add build script"
build_script = "rspack --config rspack.config.js"

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
