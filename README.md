# JavaScript Bundling for Rails

Use [esbuild](https://esbuild.github.io), [rollup.js](https://rollupjs.org), or [Webpack](https://webpack.js.org) to bundle your JavaScript, then deliver it via the asset pipeline in Rails. This gem provides installers to get you going with the bundler of your choice in a new Rails application, and a convention to use `app/assets/bundles` to hold your bundled output as artifacts that are not checked into source control (the installer adds this directory to `.gitignore` by default).

You develop using this approach by running the bundler in watch mode in a terminal with `yarn build --watch` (and your Rails server in another, if you're not using something like [puma-dev](https://github.com/puma/puma-dev)). Whenever the bundler detects changes to any of the JavaScript files in your project, it'll bundle `app/javascript/application.js` into `app/assets/bundles/javascript.js` (and all other entry points placed in the root of `app/javascript`). You can refer to the build output in your layout using the standard asset pipeline approach with `<%= javascript_include_tag "application" %>`.

When you deploy your application to production, the bundler attaches to the `assets:precompile` task to ensure that all your package dependencies from `package.json` have been installed via npm, and then runs `yarn build` to process all the entry points, as it would in development. The latter files are then picked up by the asset pipeline, digested, and copied into public/assets, as any other asset pipeline file.

This also happens in testing where the bundler attaches to the `test:prepare` task to ensure the JavaScript has been bundled before testing commences. (Note that this currently only applies to rails `test:*` tasks (like `test:all` or `test:controllers`), not "rails test", as that doesn't load `test:prepare`).

That's it!

You can configure your bundler options in the `build` script in `package.json` or via the installer-generated rollup.config.js for rollup.js or webpack.config.json for Webpack (esbuild does not have a default configuration format).


## Installation

You must already have node and yarn installed on your system. Then:

1. Add `jsbundling-rails` to your Gemfile with `gem 'jsbundling-rails'`
2. Run `./bin/bundle install`
3. Run `./bin/rails javascript:[rollup|esbuild|webpack]:install`

Or, in Rails 7+, you can preconfigure your new application to use a specific bundler with `rails new myapp -j [rollup|esbuild|webpack]`.


## License

rollup.js for Rails is released under the [MIT License](https://opensource.org/licenses/MIT).
