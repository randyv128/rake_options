# Requirements Document

## Introduction

RakeCommander is a Ruby gem designed to simplify command line argument handling for rake tasks. It provides an intuitive API that allows developers to easily parse and access command line arguments without dealing with complex parsing logic. The gem supports multiple notation styles (CLI-style with dashes and bracket-style) and includes automatic help documentation generation.

## Requirements

### Requirement 1: Command Line Argument Parsing

**User Story:** As a rake task developer, I want to easily parse command line arguments using a simple configuration hash, so that I can access user-provided values without writing custom parsing logic.

#### Acceptance Criteria

1. WHEN a developer calls `RakeCommander.command_line_args(arg_config)` THEN the system SHALL return a hash containing parsed argument values
2. WHEN the arg_config contains a key-value mapping like `{"with-mysql-lib": "--with-mysql-lib $path"}` THEN the system SHALL extract the value from command line arguments matching the pattern
3. WHEN a user provides `--with-mysql-lib "some-path"` on the command line THEN the system SHALL map it to the corresponding key in the returned options hash
4. WHEN an argument is defined in arg_config but not provided by the user THEN the system SHALL return nil or a default value for that key
5. WHEN the command line contains arguments not defined in arg_config THEN the system SHALL ignore them without raising errors

### Requirement 2: Multiple Notation Style Support

**User Story:** As a rake task developer, I want to support different argument notation styles (CLI-style and bracket-style), so that users can provide arguments in their preferred format.

#### Acceptance Criteria

1. WHEN a developer calls `RakeCommander.command_line_args(config, notation: :cli)` THEN the system SHALL parse arguments in CLI format (e.g., `--with-mysql-lib "value"`)
2. WHEN a developer calls `RakeCommander.command_line_args(config, notation: :bracket)` THEN the system SHALL parse arguments in bracket format (e.g., `[with-mysql-lib=value]`)
3. WHEN no notation parameter is provided THEN the system SHALL default to CLI notation style
4. WHEN an invalid notation style is provided THEN the system SHALL raise an informative error
5. WHEN using bracket notation THEN the system SHALL support both `[key=value]` and `[key="value with spaces"]` formats

### Requirement 3: Automatic Help Documentation

**User Story:** As a rake task developer, I want to automatically generate help documentation from a README or configuration, so that users can invoke `--help` to see available options.

#### Acceptance Criteria

1. WHEN a developer calls `RakeCommander.initialize_readme(readme_content)` THEN the system SHALL configure help documentation for the rake task
2. WHEN a user invokes the rake task with `--help` flag THEN the system SHALL display the configured help documentation and exit
3. WHEN help documentation is displayed THEN the system SHALL include all available argument options from the arg_config
4. WHEN help documentation is displayed THEN the system SHALL format the output in a readable manner with argument names and descriptions
5. WHEN `initialize_readme` is not called THEN the system SHALL still support `--help` with auto-generated documentation from arg_config

### Requirement 4: Template-Based Argument Extraction

**User Story:** As a rake task developer, I want to define argument patterns using template syntax, so that I can specify how values should be extracted from command line input.

#### Acceptance Criteria

1. WHEN an arg_config uses template syntax like `"--with-mysql-lib $path"` THEN the system SHALL extract the value following the flag into the variable
2. WHEN a template contains multiple variables like `"--config $file --env $environment"` THEN the system SHALL extract both values correctly
3. WHEN a template variable is prefixed with `$` THEN the system SHALL treat it as a placeholder for user input
4. WHEN the command line input matches the template pattern THEN the system SHALL return the extracted value(s)
5. WHEN the command line input does not match the template pattern THEN the system SHALL return nil or raise a descriptive error

### Requirement 5: Simple Integration API

**User Story:** As a rake task developer, I want a minimal API surface that requires just one or two method calls, so that I can integrate RakeCommander quickly without learning complex configurations.

#### Acceptance Criteria

1. WHEN integrating RakeCommander THEN the developer SHALL only need to call `command_line_args(config)` to parse arguments
2. WHEN the developer wants help documentation THEN they SHALL only need to additionally call `initialize_readme(content)`
3. WHEN using RakeCommander THEN the system SHALL not require inheritance or complex setup in the rake task
4. WHEN the returned options hash is accessed THEN it SHALL support both string and symbol key access
5. WHEN errors occur during parsing THEN the system SHALL provide clear, actionable error messages

### Requirement 6: Gem Distribution and Installation

**User Story:** As a Ruby developer, I want to install RakeCommander as a standard Ruby gem, so that I can easily add it to my project dependencies.

#### Acceptance Criteria

1. WHEN a developer runs `gem install rake_commander` THEN the system SHALL install the gem successfully
2. WHEN a developer adds `gem 'rake_commander'` to their Gemfile THEN Bundler SHALL resolve and install the dependency
3. WHEN the gem is installed THEN it SHALL be compatible with Ruby 2.7 and above
4. WHEN the gem is installed THEN it SHALL include all necessary dependencies
5. WHEN requiring the gem with `require 'rake_commander'` THEN all public APIs SHALL be available
