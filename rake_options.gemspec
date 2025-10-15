# frozen_string_literal: true

require_relative "lib/rake_options/version"

Gem::Specification.new do |spec|
  spec.name = "rake_options"
  spec.version = RakeOptions::VERSION
  spec.authors = ["Randy Villanueva"]
  spec.email = ["randyv128@gmail.com"]

  spec.summary = "Simplify command line argument handling for rake tasks"
  spec.description = "RakeOptions provides an intuitive API for parsing command line arguments in rake tasks with support for multiple notation styles and automatic help documentation generation."
  spec.homepage = "https://github.com/randyv128/rake_options"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.7.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/main/CHANGELOG.md"
  spec.metadata["allowed_push_host"] = "https://rubygems.org"
  # Specify which files should be added to the gem when it is released.
  spec.files = Dir.glob("{lib,spec}/**/*") + %w[README.md LICENSE Rakefile]
  spec.require_paths = ["lib"]

  # Runtime dependencies
  # Keeping dependencies minimal as per design

  # Development dependencies
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
