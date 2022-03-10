# Comparison with `webpacker` (`shakapacker`)

If you're already using [`webpacker`](https://github.com/rails/webpacker), you may be wondering how it compares to `jsbundling-rails` and whether you should migrate or migrate to `shakapacker` the official fork of `webpacker`. Note, the `shakapacker` fork still uses `webpacker` name within the project, allowing an easy trial. So the below discussion applies to **v6+** of `webpacker`/`shakapacker` vs `jsbundling-rails`.

Here are some considerations between the two:

- `jsbundling-rails` is a simple integration composed only of installed files and a couple of new rake tasks. `webpacker`/`shakapacker`, on the other hand, provides view helpers and a customizable webpack config that include support for the most important advanced features of webpack: code splitting and HMR. You don't need to use the `webpacker` webpack config. You could choose only to use the view helper portion of `webpacker`/`shakapacker`.
- `jsbundling-rails` can be used with multiple bundlers (currently `esbuild`, `rollup`, and `webpack` are supported out of the box, but anything that can put a bundle into `app/assets/builds` could be configured to work with it). `webpacker`/`shakapacker` is built specifically to integrate with `webpack`. That allows `webpacker` to provide support for HMR and code splitting. 
- `jsbundling-rails` doesn't tie you to specific versions of the JavaScript packages you use for bundling, transpiling, etc.
  `webpacker`/`shakapacker` releases are also not tied to a specific major version of `webpack`, `babel`, etc. as these are handled because webpacker specifies these as _peer dependencies_.
- `jsbundling-rails` uses the standard configuration format for your bundler of choice.
  `webpacker`/`shakapacker` has an optional configuration layer on top of `webpack`'s configuration. You don't have to use it. The only requirement of webpacker is that your webpack configuration must produce a manifest.
- `jsbundling-rails` works with the standard [`actionview` asset helpers](https://api.rubyonrails.org/classes/ActionView/Helpers/AssetUrlHelper.html).
  `webpacker`/`shakapacker` provides view helpers with an almost identical API.
- `webpacker`/`shakapacker` can be used as a complete replacement for [`sprockets`](https://github.com/rails/sprockets), and in that setup you can stop loading the `sprockets/railtie` in your application. What you produce in the webpack ecosystem is what is sent to the browser.
  `jsbundling-rails` (as well as [`css-bundling-rails`](https://github.com/rails/cssbundling-rails)) works in conjunction with `sprockets`. Because of this, you need to be sure not to double fingerprint your assets in both `webpack` and `sprockets`. You might also have issues with source maps due to double fingerprinting of output files.
- `webpacker`/`shakapacker` supports using the `webpack-dev-server` for hot reloading. HMR enables you to see your changes in the browser almost immediately as you make them, usually without the need to refresh the page or lose your application state. 
  `jsbundling-rails` hands over static files to `sprockets`, so hot reloading is not supported. To load any JavaScript changes, you'll need to do a local-state-clearing full page refresh.
- `webpacker`/`shakapacker` delegates asset processing entirely to the external nodejs tooling.
  `jsbundling-rails` still relies on `sprockets` to output the final `public` assets and create the associated manifest.
  `webpacker`'s complete control over the resulting webpack output files allow it to integrate additional features like automatic [code splitting](https://webpack.js.org/guides/code-splitting/).  Webpack provides advanced optimization to split your statically `import`ed shared dependencies. The `webpacker`/`shakapacker` view helpers will automatically specify each entry point's dependent chunks for you in the resulting HTML.
  With `jsbundling-rails`, you'll be able to manually split out lazy-loaded chunks by using dynamic `import()`s. However, the manual approach would be challenging to maintain on a large project.
  Why is this important? Code splitting allows the browser to download only the JavasScript and CSS needed for a page, improving performance and SEO.
