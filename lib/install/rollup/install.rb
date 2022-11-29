say "Install rollup with config"
copy_file "#{__dir__}/rollup.config.js", "rollup.config.js"
run "yarn add rollup @rollup/plugin-node-resolve"

say "Add build script"
build_script = "rollup -c rollup.config.js"

npm_supports_set_script = ->(n) { n >= 7.1 && n < 8.0 }
npm_supports_pkg_set = ->(n) { n >= 8.0 }

case `npx -v`.to_f
when npm_supports_pkg_set
  run %(npm pkg set scripts.build="#{build_script}")
  run %(yarn build)
when npm_supports_set_script
  run %(npm set-script build "#{build_script}")
  run %(yarn build)
else
  say %(Add "scripts": { "build": "#{build_script}" } to your package.json), :green
end
