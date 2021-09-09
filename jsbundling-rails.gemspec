require_relative "lib/jsbundling/version"

Gem::Specification.new do |spec|
  spec.name        = "jsbundling-rails"
  spec.version     = Jsbundling::VERSION
  spec.authors     = [ "David Heinemeier Hansson" ]
  spec.email       = "david@loudthinking.com"
  spec.homepage    = "https://github.com/rails/jsbundling-rails"
  spec.summary     = "Bundle and transpile JavaScript in Rails with esbuild, rollup.js, or Webpack."
  spec.license     = "MIT"

  spec.files = Dir["lib/**/*", "MIT-LICENSE", "README.md"]

  spec.add_dependency "railties", ">= 6.0.0"
  spec.add_dependency "sprockets-rails", ">= 2.0.0"
end
