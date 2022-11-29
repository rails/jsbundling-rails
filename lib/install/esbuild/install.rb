say "Install esbuild"
run "yarn add esbuild"

say "Add build script"
build_script = "esbuild app/javascript/*.* --bundle --sourcemap --outdir=app/assets/builds --public-path=assets"

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
