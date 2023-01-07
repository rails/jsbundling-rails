import resolve from "@rollup/plugin-node-resolve"

export default {
  input: "app/javascript/application.js",
  output: {
    file: "app/assets/builds/application.js",
    format: "iife",
    inlineDynamicImports: true,
    sourcemap: true
  },
  plugins: [
    resolve()
  ]
}
