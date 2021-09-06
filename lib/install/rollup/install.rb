say "Create default package.json and install rollup with config"
copy_file "#{__dir__}/package.json", "package.json"
copy_file "#{__dir__}/rollup.config.js", "rollup.config.js"
run "yarn add rollup @rollup/plugin-node-resolve"
