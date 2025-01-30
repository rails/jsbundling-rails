const path    = require("path")
const rspack = require('@rspack/core');

module.exports = {
  mode: "production",
  devtool: "source-map",
  entry: {
    application: "./app/javascript/application.js"
  },
  output: {
    filename: "[name].js",
    sourceMapFilename: "[file].map",
    chunkFormat: "module",
    path: path.resolve(__dirname, "app/assets/builds"),
  },
  plugins: [
    new rspack.optimize.LimitChunkCountPlugin({
      maxChunks: 1
    })
  ]
}
