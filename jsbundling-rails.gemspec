require_relative "lib/jsbundling/version"

Gem::Specification.new do |spec|
  spec.name        = "jsbundling-rails"
  spec.version     = Jsbundling::VERSION
  spec.authors     = [ "David Heinemeier Hansson" ]
  spec.email       = "david@loudthinking.com"
  spec.homepage    = "https://github.com/rails/jsbundling-rails"
  spec.summary     = "Bundle and transpile JavaScript in Rails with bun, esbuild, rollup.js, or Webpack."
  spec.license     = "MIT"

  spec.files = Dir.glob("lib/**/*", File::FNM_DOTMATCH).reject { |f| File.directory?(f) }
  spec.files += ["MIT-LICENSE", "README.md"]

  spec.add_dependency "railties", ">= 6.0.0"

  spec.metadata["changelog_uri"] = spec.homepage + "/releases"
end
