say "Create default package.json and install Webpack with config"
copy_file "#{__dir__}/package.json", "package.json"
copy_file "#{__dir__}/webpack.config.js", "webpack.config.js"
run "yarn add webpack webpack-cli"
