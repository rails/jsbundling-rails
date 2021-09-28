stdout, _stderr, _status = Open3.capture3("npx -v")
npx_version = stdout.match(/\d.\d+/).to_s.to_f

if npx_version < 7.1
  say "Failed. Upgrade npx to version 7.1 or later and run install script again", :red
  abort
end

say "Install esbuild"
run "yarn add esbuild"

say "Add build script"
run %(npm set-script build "esbuild app/javascript/*.* --bundle --outdir=app/assets/builds")
