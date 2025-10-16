# RakeOptions

RakeOptions is a Ruby gem that simplifies command line argument handling for rake tasks. It provides an intuitive API for parsing CLI-style arguments with automatic type casting, required/optional validation, and automatic help documentation generation.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rake_options'
```

And then execute:

```bash
bundle install
```

Or install it yourself as:

```bash
gem install rake_options
```

## Usage

### Basic CLI-Style Arguments

```ruby
require 'rake_options'

desc "Build with custom options"
task :build do
  # Configuration: [flag_name, type, requirement, description]
  config = [
    ["with-mysql-lib", :string, :required, "Path to MySQL library"],
    ["enable-feature", :string, :optional, "Feature to enable"],
    ["port", :integer, :optional, "Port number"]
  ]
  
  options = RakeOptions.command_line_args(config)
  
  puts "MySQL lib path: #{options['with-mysql-lib']}"
  puts "Feature: #{options['enable-feature']}"
  puts "Port: #{options['port']}"  # Automatically cast to integer
end
```

Run with:
```bash
rake build -- --with-mysql-lib=/usr/local/mysql/lib --enable-feature=caching --port=3000
```

For values with spaces, use quotes:
```bash
rake build -- --with-mysql-lib="/path/with spaces/lib"
```

**Note**: Required arguments will raise an error if not provided.

### Type Casting and Requirements

RakeOptions automatically casts values to the specified type and validates required arguments:

```ruby
config = [
  ["port", :integer, :required, "Server port number"],
  ["enabled", :boolean, :optional, "Enable feature flag"],
  ["ratio", :float, :optional, "Scaling ratio"],
  ["name", :string, :required, "Application name"]
]

options = RakeOptions.command_line_args(config)

# Values are automatically cast:
options['port']     # => 3000 (Integer)
options['enabled']  # => true (Boolean)
options['ratio']    # => 1.5 (Float)
options['name']     # => "myapp" (String)
```

**Supported types:**
- `:string` - String values
- `:integer` or `:int` - Integer values
- `:float` - Float values
- `:boolean` or `:bool` - Boolean values (true/false)

**Requirements:**
- `:required` - Must be provided or raises ArgumentError
- `:optional` - Can be omitted (returns nil)



### Automatic Help Documentation

```ruby
require 'rake_options'

# Set a brief summary for the help display
RakeOptions.initialize_readme_summary(<<~SUMMARY)
  Build Task - Compile and configure the application
  
  Usage: rake build -- [options]
SUMMARY

desc "Build with help support"
task :build do
  config = [
    ["with-mysql-lib", :string, :required, "Path to MySQL library"],
    ["enable-feature", :string, :optional, "Feature to enable"],
    ["port", :integer, :optional, "Port number"]
  ]
  
  options = RakeOptions.command_line_args(config)
  # Your build logic here
end
```

Run with:
```bash
rake build -- --help
```

Output:
```
Build Task - Compile and configure the application

Usage: rake build -- [options]

Available Options:

  --with-mysql-lib=VALUE       (string) [REQUIRED]
      Path to MySQL library
  --enable-feature=VALUE       (string)
      Feature to enable
  --port=VALUE                 (integer)
      Port number
```

### Hash Access with Strings or Symbols

The returned options hash supports both string and symbol key access:

```ruby
options = RakeOptions.command_line_args(config)

# Both work:
options['with-mysql-lib']
options[:with_mysql_lib]
```

## Configuration Format

The configuration is an array of tuples with 4 elements:

```ruby
[
  ["flag-name", :type, :requirement, "description"],
  ["another-flag", :type, :requirement, "description"]
]
```

- **flag-name**: The CLI flag name (will become `--flag-name`)
- **type**: The data type (`:string`, `:integer`, `:float`, `:boolean`)
- **requirement**: Either `:required` or `:optional`
- **description**: Help text describing the option

### Examples

```ruby
# Required string value
["mysql-path", :string, :required, "Path to MySQL installation"]

# Optional integer value
["port", :integer, :optional, "Server port number"]

# Required boolean flag
["enabled", :boolean, :required, "Enable the feature"]

# Optional float value
["ratio", :float, :optional, "Scaling ratio"]
```

**Short format** (for backward compatibility):
```ruby
["flag-name", :type]  # Defaults to :optional with no description
```

## Usage Format

RakeOptions uses standard CLI flag format:

```ruby
options = RakeOptions.command_line_args(config)
```

Supports:
- `--flag=value`
- `--flag="value with spaces"`
- Multiple flags in one command

## Error Handling

RakeOptions provides clear error messages:

```ruby
# Invalid notation
RakeOptions.command_line_args(config, notation: :invalid)
# => InvalidNotationError: Invalid notation ':invalid'. Supported notations: :cli, :bracket

# Missing optional arguments return nil
options['missing-arg']  # => nil
```

## Troubleshooting

### Arguments not being parsed

**Problem**: Your arguments aren't being recognized.

**Solution**: Make sure you're using `--` to separate rake arguments from your custom arguments:
```bash
rake task -- --your-flag value
```

### Symbol vs String keys

**Problem**: Can't access values with symbol keys.

**Solution**: RakeOptions returns a `HashWithIndifferentAccess` that supports both:
```ruby
options[:key]        # Works
options['key']       # Also works
options[:key_name]   # Converts underscores to dashes automatically
options['key-name']  # Same value
```

### Help not displaying

**Problem**: `--help` flag doesn't show help.

**Solution**: Ensure `--help` is in ARGV before calling `command_line_args`:
```bash
rake task -- --help
```

### Quoted values not working

**Problem**: Values with spaces aren't being captured correctly.

**Solution**: Use quotes around values with spaces:
```bash
rake task -- --path="/path/with spaces"
```

### Flag name mismatch

**Problem**: Arguments aren't being recognized.

**Solution**: Ensure the flag name in ARGV matches the config:
```ruby
# Config
["my-option", :string]

# Command line must match exactly
rake task -- --my-option=myvalue
```

## Requirements

- Ruby 2.7 or higher

## Development

After checking out the repo, run:

```bash
bundle install
```

Run tests:

```bash
rake spec
```

Build the gem:

```bash
gem build rake_options.gemspec
```

## Contributing

Bug reports and pull requests are welcome on GitHub.

## License

The gem is available as open source under the terms of the [MIT License](LICENSE).
