say "Install Webpack with config"
copy_file "#{__dir__}/webpack.config.js", "webpack.config.js"
run "yarn add webpack webpack-cli"

say "Add build script"
run %(npm set-script build "webpack --config webpack.config.js")
