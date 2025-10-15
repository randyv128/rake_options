# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2025-10-15

### Added
- Initial release of RakeOptions
- CLI-style argument parsing with `--flag value` syntax
- Bracket-style argument parsing with `[key=value]` syntax
- Template-based value extraction using `$variable` placeholders
- Support for multiple variables in single template
- Automatic help documentation generation
- Custom README support for help display
- HashWithIndifferentAccess for flexible key access (string/symbol)
- Support for quoted values with spaces
- Graceful handling of missing optional arguments
- Clear error messages for invalid notation
- Comprehensive test suite with 64 examples

### Features
- **TemplateEngine**: Pattern matching and value extraction from command line arguments
- **CLIParser**: Parse CLI-style arguments (`--flag value`)
- **BracketParser**: Parse bracket-style arguments (`[key=value]`)
- **HelpGenerator**: Automatic help documentation with `--help` flag
- **ArgumentParser**: Orchestrates parsing with notation validation
- **HashWithIndifferentAccess**: Flexible hash key access with dash/underscore conversion

### Requirements
- Ruby 2.7 or higher
- No runtime dependencies (minimal design)

[0.1.0]: https://github.com/randyv128/rake_options/releases/tag/v0.1.0
