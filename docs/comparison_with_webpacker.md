# Comparison with `webpacker`

If you're already using [`webpacker`](https://github.com/rails/webpacker), you may be wondering how it compares to `jsbundling-rails` and whether you should migrate or stick with `webpacker`. Here are some considerations:

- `jsbundling-rails` is a much more lightweight integration.
  `webpacker` is more involved and opinionated.
- `jsbundling-rails` can be used with multiple bundlers (currently `esbuild`, `rollup`, and `webpack` are supported out of the box, but anything that can put a bundle into `app/assets/builds` could be configured to work with it).
  `webpacker` is built specifically to integrate with `webpack`.
- `jsbundling-rails` doesn't tie you to specific versions of the JavaScript packages you use for bundling, transpiling, etc.
  `webpacker` releases are tied to a specific major version of `webpack`, `babel`, etc.
   This means you cannot freely upgrade those packages - you have to wait for a new `webpacker` major release that supports the newer versions, and upgrading to that new `webpacker`  release requires upgrading to all of those new JavaScript package versions at once.
- `jsbundling-rails` uses the standard configuration format for your bundler of choice.
  `webpacker` has its own configuration layer on top of `webpack`'s configuration, which requires you to do some translation when following guides/documentation written directly for `webpack`.
- `jsbundling-rails` works with the standard [`actionview` asset helpers](https://api.rubyonrails.org/classes/ActionView/Helpers/AssetUrlHelper.html).
  `webpacker` provides its own tag helpers that you need to use.
- `webpacker` can be used as a complete replacement for [`sprockets`](https://github.com/rails/sprockets), and in that setup you can stop loading the `sprockets/railtie` in your application.
  `jsbundling-rails` (as well as [`css-bundling-rails`](https://github.com/rails/cssbundling-rails)) works in conjunction with `sprockets`.
- `webpacker` supports using a dev server for hot reloading.
  `jsbundling-rails` hands off static files to `sprockets`, so hot reloading is not supported (i.e. to load any JavaScript changes, you'll need to do a local-state-clearing full page refresh).
- `webpacker` delegates asset processing entirely to the external nodejs tooling.
  `jsbundling-rails` still relies on `sprockets` to output the final `public` assets and create the associated manifest.
  When `webpack` has full control over the end result, it can integrate additional features like automatic code splitting of statically `import`ed shared dependencies, and `webpacker` can load each entry point's dependent chunks for you.
  With `jsbundling-rails`, you'll be able to manually split out lazy loaded chunks by using dynamic `import()`s.
