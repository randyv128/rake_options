# RakeOptions

RakeOptions is a Ruby gem that simplifies command line argument handling for rake tasks. It provides an intuitive API for parsing arguments with support for multiple notation styles and automatic help documentation generation.

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
  # Simple array configuration: [flag_name, type]
  config = [
    ["with-mysql-lib", :string],
    ["enable-feature", :string],
    ["port", :integer]
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

### Type Casting

RakeOptions automatically casts values to the specified type:

```ruby
config = [
  ["port", :integer],
  ["enabled", :boolean],
  ["ratio", :float],
  ["name", :string]
]

options = RakeOptions.command_line_args(config)

# Values are automatically cast:
options['port']     # => 3000 (Integer)
options['enabled']  # => true (Boolean)
options['ratio']    # => 1.5 (Float)
options['name']     # => "myapp" (String)
```

Supported types:
- `:string` - String values (default)
- `:integer` or `:int` - Integer values
- `:float` - Float values
- `:boolean` or `:bool` - Boolean values (true/false)

### Bracket-Style Arguments

```ruby
require 'rake_options'

desc "Deploy with bracket notation"
task :deploy do
  config = [
    ["environment", :string],
    ["region", :string]
  ]
  
  options = RakeOptions.command_line_args(config, notation: :bracket)
  
  puts "Deploying to #{options['environment']} in #{options['region']}"
end
```

Run with:
```bash
rake deploy [environment=production] [region=us-west-2]
```

### Automatic Help Documentation

```ruby
require 'rake_options'

readme_content = <<~HELP
  Build Task Help
  
  Available options:
    --with-mysql-lib=PATH    Specify MySQL library path (string)
    --enable-feature=NAME    Enable a specific feature (string)
    --port=NUMBER            Port number (integer)
HELP

RakeOptions.initialize_readme(readme_content)

desc "Build with help support"
task :build do
  config = [
    ["with-mysql-lib", :string],
    ["enable-feature", :string],
    ["port", :integer]
  ]
  
  options = RakeOptions.command_line_args(config)
  # Your build logic here
end
```

Run with:
```bash
rake build -- --help
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

The configuration is a simple array of tuples:

```ruby
[
  ["flag-name", :type],
  ["another-flag", :type]
]
```

- **flag-name**: The CLI flag name (will become `--flag-name`)
- **type**: The data type (`:string`, `:integer`, `:float`, `:boolean`)

### Examples

```ruby
# String values
["mysql-path", :string]

# Integer values
["port", :integer]

# Boolean flags
["enabled", :boolean]

# Float values
["ratio", :float]
```

## Notation Styles

### CLI Notation (default)

```ruby
options = RakeOptions.command_line_args(config, notation: :cli)
```

Supports:
- `--flag=value`
- `--flag="value with spaces"`
- Multiple flags in one command

### Bracket Notation

```ruby
options = RakeOptions.command_line_args(config, notation: :bracket)
```

Supports:
- `[key=value]`
- `[key="value with spaces"]`
- Multiple bracket arguments

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
