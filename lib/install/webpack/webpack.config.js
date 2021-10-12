const path    = require("path")

module.exports = {
  mode: "production",
  devtool: "source-map",
  entry: {
    application: "./app/javascript/application.js"
  },
  output: {
    filename: '[name].js',
    chunkFilename: '[name]-[contenthash].digested.js',
    sourceMapFilename: '[name]-[contenthash].digested.js.map',
    path: path.resolve(__dirname, "app/assets/builds"),
  }
}
