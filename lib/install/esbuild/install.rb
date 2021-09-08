say "Install esbuild"
run "yarn add esbuild"

say "Add build script"
run %(npm set-script build "esbuild app/javascript/*.* --bundle --outdir=app/assets/builds")
