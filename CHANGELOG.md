# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.3] - 2025-10-15

### Removed
- **BREAKING CHANGE**: Removed bracket notation support
- Removed `notation:` parameter from `command_line_args` method
- Deleted ArgumentParser and BracketParser classes
- Removed all bracket notation tests and documentation

### Changed
- Simplified API to single format: `RakeOptions.command_line_args(config)`
- Now only supports CLI format: `--flag=value`

### Benefits
- No whitespace/quoting issues with bracket notation
- Simpler, cleaner API
- Less code to maintain
- Single clear format for all users

### Migration Guide
```ruby
# Old format (0.1.2)
options = RakeOptions.command_line_args(config, notation: :cli)
options = RakeOptions.command_line_args(config, notation: :bracket)

# New format (0.1.3)
options = RakeOptions.command_line_args(config)
```

## [0.1.2] - 2025-10-15

### Changed
- **BREAKING CHANGE**: Simplified configuration from hash to array of tuples
- Configuration now uses simple format: `[["flag-name", :type]]`
- Added automatic type casting for `:string`, `:integer`, `:float`, `:boolean`
- Removed template syntax - flags are auto-generated from names
- No need to specify `--flag` in config - automatically created

### Benefits
- Much simpler and more intuitive API
- No template syntax to learn
- Automatic type conversion
- Less error-prone configuration
- Cleaner code

### Migration Guide
```ruby
# Old format (0.1.1)
config = {
  "port" => "--port $number",
  "name" => "--name $value"
}

# New format (0.1.2)
config = [
  ["port", :integer],
  ["name", :string]
]
```

## [0.1.1] - 2025-10-15

### Changed
- **BREAKING CHANGE**: CLI arguments now use `--flag=value` format instead of `--flag value`
- Simplified argument passing by requiring equal sign between flag and value
- Eliminates ambiguity with whitespace and follows common CLI conventions
- Values with spaces now use `--flag="value with spaces"` format

### Benefits
- More robust parsing without whitespace issues
- Follows standard CLI patterns (similar to curl, git config, etc.)
- Simpler to use - no need to worry about shell word splitting
- Clearer syntax that's less error-prone

### Migration Guide
- Change `--flag value` to `--flag=value`
- Change `--flag "value with spaces"` to `--flag="value with spaces"`

## [0.1.0] - 2025-10-15

### Added
- Initial release of RakeOptions
- CLI-style argument parsing with `--flag=value` syntax (using = sign to avoid whitespace issues)
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

[0.1.3]: https://github.com/randyv128/rake_options/releases/tag/v0.1.3
[0.1.2]: https://github.com/randyv128/rake_options/releases/tag/v0.1.2
[0.1.1]: https://github.com/randyv128/rake_options/releases/tag/v0.1.1
[0.1.0]: https://github.com/randyv128/rake_options/releases/tag/v0.1.0
