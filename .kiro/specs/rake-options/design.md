# RakeOptions Design Document

## Overview

RakeOptions is a Ruby gem that provides a simple, declarative API for parsing command line arguments in rake tasks. The gem uses a template-based configuration system to map command line inputs to structured data, supports multiple notation styles, and automatically generates help documentation.

The design emphasizes simplicity and ease of use, requiring minimal integration code while providing powerful argument parsing capabilities.

## Architecture

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────┐
│                     Rake Task                           │
│  options = RakeOptions.command_line_args(config)      │
│  RakeOptions.initialize_readme(readme)                │
└────────────────────┬────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────┐
│                  RakeOptions                          │
│                  (Main Module)                          │
└────────┬────────────────────────┬───────────────────────┘
         │                        │
         ▼                        ▼
┌──────────────────┐    ┌──────────────────────┐
│  ArgumentParser  │    │   HelpGenerator      │
│                  │    │                      │
│  - CLIParser     │    │  - Format help text  │
│  - BracketParser │    │  - Display & exit    │
└──────────────────┘    └──────────────────────┘
         │
         ▼
┌──────────────────┐
│ TemplateEngine   │
│                  │
│ - Parse template │
│ - Extract values │
└──────────────────┘
```

### Module Structure

```
RakeOptions/
├── rake_options.rb          # Main module with public API
├── argument_parser.rb         # Orchestrates parsing logic
├── cli_parser.rb              # CLI notation parser
├── bracket_parser.rb          # Bracket notation parser
├── template_engine.rb         # Template pattern matching
├── help_generator.rb          # Help documentation generator
└── errors.rb                  # Custom error classes
```

## Components and Interfaces

### 1. RakeOptions Module (Main API)

The main entry point providing the public API.

```ruby
module RakeOptions
  class << self
    # Parse command line arguments based on configuration
    # @param config [Hash] Argument configuration mapping
    # @param notation [Symbol] Notation style (:cli or :bracket)
    # @return [Hash] Parsed arguments with indifferent access
    def command_line_args(config, notation: :cli)
    end

    # Initialize help documentation
    # @param readme_content [String] Help text or README content
    # @return [void]
    def initialize_readme(readme_content)
    end
  end
end
```

**Responsibilities:**
- Provide simple public API
- Delegate to appropriate parser based on notation
- Handle --help flag detection
- Return HashWithIndifferentAccess for convenience

### 2. ArgumentParser

Orchestrates the parsing process and coordinates between components.

```ruby
class RakeOptions::ArgumentParser
  # @param config [Hash] Argument configuration
  # @param notation [Symbol] Notation style
  def initialize(config, notation)
  end

  # Parse ARGV and return structured options
  # @return [Hash] Parsed options
  def parse
  end

  private

  def select_parser
    # Returns CLIParser or BracketParser based on notation
  end

  def validate_notation
    # Ensures notation is valid
  end
end
```

**Responsibilities:**
- Validate notation parameter
- Select appropriate parser (CLI or Bracket)
- Coordinate parsing workflow
- Handle parsing errors

### 3. CLIParser

Parses CLI-style arguments (--flag value).

```ruby
class RakeOptions::CLIParser
  # @param config [Hash] Argument configuration
  def initialize(config)
  end

  # Parse CLI-style arguments from ARGV
  # @return [Hash] Parsed values
  def parse(argv = ARGV)
  end

  private

  def extract_flag_and_template(config_value)
    # Extracts flag name and template pattern
  end

  def match_and_extract(argv, flag, template)
    # Matches template against argv and extracts values
  end
end
```

**Responsibilities:**
- Parse --flag style arguments
- Handle quoted values with spaces
- Support multiple flags in single invocation
- Extract values based on template patterns

### 4. BracketParser

Parses bracket-style arguments [key=value].

```ruby
class RakeOptions::BracketParser
  # @param config [Hash] Argument configuration
  def initialize(config)
  end

  # Parse bracket-style arguments from ARGV
  # @return [Hash] Parsed values
  def parse(argv = ARGV)
  end

  private

  def extract_bracket_args(argv)
    # Finds all [key=value] patterns
  end

  def parse_bracket_value(value)
    # Handles quoted and unquoted values
  end
end
```

**Responsibilities:**
- Parse [key=value] style arguments
- Handle quoted values in brackets
- Map bracket keys to config keys
- Support multiple bracket arguments

### 5. TemplateEngine

Handles template pattern matching and value extraction.

```ruby
class RakeOptions::TemplateEngine
  # Parse a template string into components
  # @param template [String] Template like "--flag $variable"
  # @return [Hash] Template structure
  def self.parse_template(template)
  end

  # Extract values from input based on template
  # @param input [Array] Input tokens
  # @param template [Hash] Parsed template structure
  # @return [Hash] Extracted variable values
  def self.extract_values(input, template)
  end

  private

  def self.identify_variables(template)
    # Finds $variable placeholders
  end

  def self.build_pattern(template)
    # Creates regex pattern from template
  end
end
```

**Responsibilities:**
- Parse template strings
- Identify variable placeholders ($var)
- Build matching patterns
- Extract values from matched input

### 6. HelpGenerator

Generates and displays help documentation.

```ruby
class RakeOptions::HelpGenerator
  # @param config [Hash] Argument configuration
  # @param readme_content [String, nil] Custom help content
  def initialize(config, readme_content = nil)
  end

  # Display help and exit
  # @return [void]
  def display_and_exit
  end

  private

  def generate_help_text
    # Creates formatted help text
  end

  def format_option(key, template)
    # Formats individual option for display
  end
end
```

**Responsibilities:**
- Generate help text from config
- Display custom README content if provided
- Format output for readability
- Exit gracefully after displaying help

### 7. Custom Errors

```ruby
module RakeOptions
  class Error < StandardError; end
  class InvalidNotationError < Error; end
  class TemplateParseError < Error; end
  class ArgumentParseError < Error; end
end
```

## Data Models

### Configuration Hash Structure

```ruby
{
  "with-mysql-lib" => "--with-mysql-lib $path",
  "enable-feature" => "--enable-feature $name",
  "config-file" => "--config $file --env $environment"
}
```

**Keys:** Symbolic names for arguments (used in returned hash)
**Values:** Template strings defining how to parse the argument

### Parsed Template Structure

```ruby
{
  flag: "--with-mysql-lib",
  variables: ["path"],
  pattern: /^--with-mysql-lib\s+(.+)$/,
  positions: { "path" => 0 }
}
```

### Return Value Structure

```ruby
# HashWithIndifferentAccess allowing both string and symbol access
{
  "with-mysql-lib" => "/usr/local/mysql/lib",
  :with_mysql_lib => "/usr/local/mysql/lib"  # Same value, symbol access
}
```

## Error Handling

### Error Scenarios and Responses

1. **Invalid Notation**
   - Trigger: Unsupported notation parameter
   - Response: Raise `InvalidNotationError` with valid options

2. **Template Parse Error**
   - Trigger: Malformed template string
   - Response: Raise `TemplateParseError` with details

3. **Argument Parse Error**
   - Trigger: Command line doesn't match any template
   - Response: Return nil for that key (graceful degradation)

4. **Help Flag Detection**
   - Trigger: --help in ARGV
   - Response: Display help and exit(0)

### Error Message Format

```ruby
"Invalid notation ':invalid'. Supported notations: :cli, :bracket"
"Failed to parse template '--flag $var $var2': duplicate variable names"
"Argument '--unknown-flag' does not match any configured pattern"
```

## Testing Strategy

### Unit Tests

1. **TemplateEngine**
   - Test template parsing with various patterns
   - Test variable extraction
   - Test edge cases (no variables, multiple variables)

2. **CLIParser**
   - Test single flag parsing
   - Test multiple flags
   - Test quoted values with spaces
   - Test missing arguments

3. **BracketParser**
   - Test [key=value] parsing
   - Test quoted bracket values
   - Test multiple bracket arguments
   - Test malformed brackets

4. **HelpGenerator**
   - Test help text generation
   - Test custom README display
   - Test formatting

### Integration Tests

1. **End-to-End CLI Parsing**
   - Simulate full rake task invocation with CLI args
   - Verify correct value extraction
   - Test multiple arguments together

2. **End-to-End Bracket Parsing**
   - Simulate rake task with bracket notation
   - Verify correct parsing
   - Test mixed bracket arguments

3. **Help Display**
   - Test --help flag triggers help display
   - Verify exit behavior
   - Test with and without custom README

### Test Fixtures

```ruby
# spec/fixtures/sample_config.rb
SAMPLE_CONFIG = {
  "with-mysql-lib" => "--with-mysql-lib $path",
  "enable-feature" => "--enable-feature $name"
}

# spec/fixtures/sample_argv.rb
CLI_ARGV = ["--with-mysql-lib", "/usr/local/lib", "--enable-feature", "caching"]
BRACKET_ARGV = ["[with-mysql-lib=/usr/local/lib]", "[enable-feature=caching]"]
```

## Implementation Considerations

### Ruby Version Compatibility
- Target Ruby 2.7+ for modern syntax support
- Use keyword arguments for clarity
- Avoid deprecated features

### Dependencies
- Minimal external dependencies
- Use stdlib where possible
- Consider `activesupport` for HashWithIndifferentAccess (or implement lightweight version)

### Performance
- Lazy parsing (only parse when called)
- Cache parsed templates
- Efficient regex patterns

### Gem Structure
- Follow standard gem conventions
- Include gemspec with metadata
- Provide clear README with examples
- Include LICENSE file (MIT recommended)

### API Design Principles
- Sensible defaults (CLI notation)
- Fail fast with clear errors
- Return nil for missing optional args
- Support both string and symbol key access
