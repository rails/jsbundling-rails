say "Install rollup with config"
copy_file "#{__dir__}/rollup.config.js", "rollup.config.js"
run "yarn add rollup @rollup/plugin-node-resolve"

say "Add build script"
run %(npm set-script build "rollup -c rollup.config.js")
