const path    = require("path")
const webpack = require('webpack')

module.exports = {
  mode: "production",
  entry: "./app/javascript/application.js",
  output: {
    filename: "application.js",
    path: path.resolve(__dirname, "app/assets/builds"),
  },
  plugins: [
    new webpack.optimize.LimitChunkCountPlugin({
      maxChunks: 1
    })
  ]
}
