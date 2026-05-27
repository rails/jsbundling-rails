import { defineConfig } from "rolldown"

export default defineConfig({
  input: "app/javascript/application.js",
  output: {
    file: "app/assets/builds/application.js",
    format: "esm",
    codeSplitting: false,
    sourcemap: true
  }
})
