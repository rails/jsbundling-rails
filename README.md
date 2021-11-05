# JavaScript Bundling for Rails

Use [esbuild](https://esbuild.github.io), [rollup.js](https://rollupjs.org), or [Webpack](https://webpack.js.org) to bundle your JavaScript, then deliver it via the asset pipeline in Rails. This gem provides installers to get you going with the bundler of your choice in a new Rails application, and a convention to use `app/assets/builds` to hold your bundled output as artifacts that are not checked into source control (the installer adds this directory to `.gitignore` by default).

You develop using this approach by running the bundler in watch mode in a terminal with `yarn build --watch` (and your Rails server in another, if you're not using something like [puma-dev](https://github.com/puma/puma-dev)). You can also use `./bin/dev`, which will start both the Rails server and the JS build watcher (along with a CSS build watcher, if you're also using `cssbundling-rails`).

Whenever the bundler detects changes to any of the JavaScript files in your project, it'll bundle `app/javascript/application.js` into `app/assets/builds/application.js` (and all other entry points configured). You can refer to the build output in your layout using the standard asset pipeline approach with `<%= javascript_include_tag "application", defer: true %>`.

When you deploy your application to production, the `javascript:build` task attaches to the `assets:precompile` task to ensure that all your package dependencies from `package.json` have been installed via yarn, and then runs `yarn build` to process all the entry points, as it would in development. The latter files are then picked up by the asset pipeline, digested, and copied into public/assets, as any other asset pipeline file.

This also happens in testing where the bundler attaches to the `test:prepare` task to ensure the JavaScript has been bundled before testing commences. (Note that this currently only applies to rails `test:*` tasks (like `test:all` or `test:controllers`), not "rails test", as that doesn't load `test:prepare`).

If your testing library of choice does not define a `test:prepare` Rake task, ensure that your test suite runs `javascript:build` to bundle JavaScript before testing commences.

That's it!

You can configure your bundler options in the `build` script in `package.json` or via the installer-generated `rollup.config.js` for rollup.js or `webpack.config.json` for Webpack (esbuild does not have a default configuration format).

If you're already using [`webpacker`](https://github.com/rails/webpacker) and you're wondering if you should migrate to `jsbundling-rails`, have a look at [the high-level comparison](./docs/comparison_with_webpacker.md).


## Installation

You must already have node and yarn installed on your system. You will also need npx version 7.1.0 or later. Then:

1. Add `jsbundling-rails` to your Gemfile with `gem 'jsbundling-rails'`
2. Run `./bin/bundle install`
3. Run `./bin/rails javascript:install:[esbuild|rollup|webpack]`

Or, in Rails 7+, you can preconfigure your new application to use a specific bundler with `rails new myapp -j [esbuild|rollup|webpack]`.


## License

JavaScript Bundling for Rails is released under the [MIT License](https://opensource.org/licenses/MIT).
