say "Create default package.json and install esbuild"
copy_file "#{__dir__}/package.json", "package.json"
run "yarn add esbuild"

say "Add build script"
run %(npm set-script build "esbuild app/javascript/*.* --bundle --outdir=app/assets/builds")
