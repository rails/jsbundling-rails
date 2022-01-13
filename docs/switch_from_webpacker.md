# Switch from Webpacker 5 to jsbundling-rails with webpack

This guide provides step-by-step instructions to migration from [`Webpacker 5`](https://github.com/rails/webpacker/tree/5-x-stable) to `jsbundling-rails` with [`webpack 4`](https://v4.webpack.js.org/concepts/). For upgrading to Webpacker 6 instead, follow [this guide](https://github.com/rails/webpacker/blob/master/docs/v6_upgrade.md) or for comparison between Webpacker and jsbundling-rails, [see this](./docs/comparison_with_webpacker.md).

## 1. Setup jsbundling-rails

First install [`jsbundling-rails`](https://github.com/rails/jsbundling-rails):

```diff
# Add to your Gemfile
+ gem 'jsbundling-rails'

# From the CLI, rebuild the bundle
./bin/bundle install

# From the CLI, create a baseline configuration
./bin/rails javascript:install:webpack
```

The installation script will:

- Add builds to the manifest
- Ignore builds from git
- Setup [`foreman`](https://github.com/ddollar/foreman) for running multiple processes
- Create `./webpack.config.js`
- Add the build script to `package.json`

### Optional: Move your webpack configuration

If you would like to minimize the diff between Webpacker and jsbundling-rails:

1. Move `./webpack.config.js` into `./config/webpack/`
2. Change the config path in `package.json`

```diff
- "build": "webpack --config ./webpack.config.js"
+ "build": "webpack --config ./config/webpack/webpack.config.js"
```

3. Change the [output path](https://github.com/rails/jsbundling-rails/blob/main/lib/install/webpack/webpack.config.js#L13) in `webpack.config.js`

```diff
- path: path.resolve(__dirname, "app/assets/builds"),
+ path: path.resolve(__dirname, '..', '..', 'app/assets/builds')
```

## 2. Remove Webpacker

1. Delete the following files

- `./bin/webpack`
- `./bin/webpack-dev-server`
- `./config/initializers/webpacker.rb`
- `./config/webpacker.yml`
- `./config/webpack/development.js`
- `./config/webpack/environment.js`
- `./config/webpack/production.js`
- `./config/webpack/test.js`

2. Remove Webpacker gem

```diff
# Remove from your Gemfile
- gem 'jsbundling-rails'
```

3. Run `./bin/bundle install`

## 3. Install dependencies

Webpacker includes [many dependencies](https://github.com/rails/webpacker/blob/5-x-stable/package.json) by default while jsbundling-rails leaves it to you. If you're only handling JavaScript with no modifications you'll only need to install `webpack-cli`. Treat the rest of this section ala-carte.

```sh
# From the CLI, add webpack-cli
yarn add webpack-cli

# Then remove Webpacker packages
yarn remove @rails/webpacker webpack-dev-server
```

### Optional: Babel

[Babel](https://babeljs.io) is used to transpile source code to earlier versions of JavaScript.

1. Install packages

```sh
# From the CLI, add babel presets
yarn add @babel/core @babel/preset-env
```

2. Configure Babel

```diff
// In package.json, add
+ "babel": {
+   "presets": ["@babel/env"]
+ }
```

3. Use the loader in webpack

```diff
// in webpack.config.js, add
module.exports = {
  module: {
    rules: [
+       {
+         test: /\.(js)$/,
+         exclude: /node_modules/,
+         use: ['babel-loader'],
+       },
    ],
  },
};
```

#### Example: Babel + React + TypeScript

You can use Babel to transpile front-end frameworks and TypeScript. This example setup uses React with TypeScript.

1. Install packages

```sh
# From the CLI, add babel presets
yarn add @babel/core @babel/preset-env @babel/react @babel/preset-typescript
```

2. Configure Babel

```diff
// In package.json, add
+ "babel": {
+   "presets": [
+     "@babel/env",
+     "@babel/react",
+     "@babel/preset-typescript"
+   ]
+ }
```

3. Configure webpack

```diff
// in webpack.config.js, add
module.exports = {
  module: {
    rules: [
+       {
+         test: /\.(js|jsx|ts|tsx|)$/,
+         exclude: /node_modules/,
+         use: ['babel-loader'],
+       },
    ],
  },
};
```

### Optional: CSS + SASS

With the right loaders, webpack can handle CSS files. This setup _only_ uses jsbundling-rails, excluding [cssbundling-rails](https://github.com/rails/cssbundling-rails) from handling files.

1. Install packages

```sh
# From the CLI, add loaders, plugins, and node sass
yarn add css-loader sass sass-loader mini-css-extract-plugin webpack-fix-style-only-entries
```

2. Configure webpack

```javascript
// In webpack.config.js

// Extracts CSS into .css file
const MiniCssExtractPlugin = require('mini-css-extract-plugin');
// Removes exported JavaScript files from CSS-only entries
// in this example, entry.custom will create a corresponding empty custom.js file
const FixStyleOnlyEntriesPlugin = require('webpack-fix-style-only-entries');

module.exports = {
  entry: {
    // add your css or sass entries
    application: [
      './app/assets/javascripts/application.js',
      './app/assets/stylesheets/application.scss',
    ],
    custom: './app/assets/stylesheets/custom.scss',
  },
  module: {
    rules: [
      // Add CSS/SASS/SCSS rule with loaders
      {
        test: /\.s[ac]ss$/i,
        use: [MiniCssExtractPlugin.loader, 'css-loader', 'sass-loader'],
      },
    ],
  },
  resolve: {
    // Add additional file types
    extensions: ['.js', '.jsx', '.scss', '.css'],
  },
  plugins: [
    // Include plugins
    new FixStyleOnlyEntriesPlugin(),
    new MiniCssExtractPlugin(),
  ],
};
```

### Optional: Fonts, Images, SVG

With the right loaders, webpack can handle other files. This setup may vary on your use, but will look something like this:

1. Install packages

```sh
yarn add file-loader
```

2. Configure webpack

```diff
// in webpack.config.js, add
module.exports = {
  module: {
    rules: [
+       {
+         test: /\.(png|jpe?g|gif|eot|woff2|woff|ttf|svg)$/i,
+         use: 'file-loader',
+       },
    ],
  },
};
```

## 4. Test your build

Confirm you have a working webpack configuration. You can rebuild the bundle with:

```sh
yarn build --progress --color
```

If you have multiple entries, it's recommended to confirm one at a time, and finally the entire bundle.

## 5. Replace Webpacker pack tags

Find + replace uses of `Webpacker`'s asset tags.

```
# Webpacker tag       # Sprockets tag
javascript_pack_tag = javascript_include_tag
stylesheet_pack_tag = stylesheet_link_tag
```

Once the tags are replaced your app should be working same as before!

## Optional: Add support for development environment

`jsbundling-rails` ships with only `production` mode. You can dramatically speed up build times during development by switching to `mode: 'development'`.

```diff
// Make the following changes in webpack.config.js
+ const mode = process.env.NODE_ENV === 'development' ? 'development' : 'production';

module.exports = {
-  mode: "production",
+  mode,
-  devtool: "source-map",
  …
+  optimization: {
+    moduleIds: 'hashed',
+  }
}
```
