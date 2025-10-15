# RakeCommander

RakeCommander is a Ruby gem that simplifies command line argument handling for rake tasks. It provides an intuitive API for parsing arguments with support for multiple notation styles and automatic help documentation generation.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rake_commander'
```

And then execute:

```bash
bundle install
```

Or install it yourself as:

```bash
gem install rake_commander
```

## Usage

### Basic CLI-Style Arguments

```ruby
require 'rake_commander'

desc "Build with custom options"
task :build do
  config = {
    "with-mysql-lib" => "--with-mysql-lib $path",
    "enable-feature" => "--enable-feature $name"
  }
  
  options = RakeCommander.command_line_args(config)
  
  puts "MySQL lib path: #{options['with-mysql-lib']}"
  puts "Feature: #{options['enable-feature']}"
end
```

Run with:
```bash
rake build -- --with-mysql-lib "/usr/local/mysql/lib" --enable-feature "caching"
```

### Bracket-Style Arguments

```ruby
require 'rake_commander'

desc "Deploy with bracket notation"
task :deploy do
  config = {
    "environment" => "[environment=$env]",
    "region" => "[region=$region]"
  }
  
  options = RakeCommander.command_line_args(config, notation: :bracket)
  
  puts "Deploying to #{options['environment']} in #{options['region']}"
end
```

Run with:
```bash
rake deploy [environment=production] [region=us-west-2]
```

### Multiple Variables in One Template

```ruby
config = {
  "database" => "--config $file --env $environment"
}

options = RakeCommander.command_line_args(config)
# Extracts both file and environment from: --config database.yml --env production
```

### Automatic Help Documentation

```ruby
require 'rake_commander'

readme_content = <<~HELP
  Build Task Help
  
  Available options:
    --with-mysql-lib PATH    Specify MySQL library path
    --enable-feature NAME    Enable a specific feature
HELP

RakeCommander.initialize_readme(readme_content)

desc "Build with help support"
task :build do
  config = {
    "with-mysql-lib" => "--with-mysql-lib $path",
    "enable-feature" => "--enable-feature $name"
  }
  
  options = RakeCommander.command_line_args(config)
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
options = RakeCommander.command_line_args(config)

# Both work:
options['with-mysql-lib']
options[:with_mysql_lib]
```

## Configuration Format

The configuration hash maps symbolic names to template patterns:

```ruby
{
  "key-name" => "template pattern with $variables"
}
```

- **Key**: The name you'll use to access the parsed value
- **Value**: A template string that defines how to extract the argument
- **Variables**: Prefixed with `$` to indicate where values should be extracted

### Template Examples

```ruby
# Single variable
"mysql-path" => "--with-mysql-lib $path"

# Multiple variables
"database" => "--config $file --env $environment"

# Bracket notation
"region" => "[region=$value]"
```

## Notation Styles

### CLI Notation (default)

```ruby
options = RakeCommander.command_line_args(config, notation: :cli)
```

Supports:
- `--flag value`
- `--flag "value with spaces"`
- Multiple flags in one command

### Bracket Notation

```ruby
options = RakeCommander.command_line_args(config, notation: :bracket)
```

Supports:
- `[key=value]`
- `[key="value with spaces"]`
- Multiple bracket arguments

## Error Handling

RakeCommander provides clear error messages:

```ruby
# Invalid notation
RakeCommander.command_line_args(config, notation: :invalid)
# => InvalidNotationError: Invalid notation ':invalid'. Supported notations: :cli, :bracket

# Missing optional arguments return nil
options['missing-arg']  # => nil
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
gem build rake_commander.gemspec
```

## Contributing

Bug reports and pull requests are welcome on GitHub.

## License

The gem is available as open source under the terms of the [MIT License](LICENSE).
