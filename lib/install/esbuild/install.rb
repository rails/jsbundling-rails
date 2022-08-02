say "Install esbuild"
copy_file "#{__dir__}/tsconfig.json", "tsconfig.json"
run "yarn add esbuild"

say "Add build script"
build_script = "esbuild \`find app/javascript -type f\` --tsconfig=./tsconfig.json --bundle --sourcemap --outdir=app/assets/builds --public-path=assets"

if (`npx -v`.to_f < 7.1 rescue "Missing")
  say %(Add "scripts": { "build": "#{build_script}" } to your package.json), :green
else
  run %(npm set-script build "#{build_script}")
  run %(yarn build)
end
