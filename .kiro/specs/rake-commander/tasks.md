# Implementation Plan

- [x] 1. Set up gem structure and dependencies
  - Create standard Ruby gem directory structure (lib, spec, bin)
  - Create rake_commander.gemspec with metadata and dependencies
  - Set up Rakefile for gem tasks
  - Create lib/rake_commander.rb as main entry point
  - _Requirements: 6.1, 6.2, 6.3, 6.4, 6.5_

- [x] 2. Implement custom error classes
  - Create lib/rake_commander/errors.rb
  - Define base Error class inheriting from StandardError
  - Define InvalidNotationError, TemplateParseError, and ArgumentParseError
  - _Requirements: 2.4, 4.5_

- [ ] 3. Implement TemplateEngine for pattern matching
  - [x] 3.1 Create lib/rake_commander/template_engine.rb
    - Implement parse_template method to extract flag and variables from template strings
    - Implement identify_variables method to find $variable placeholders
    - Implement build_pattern method to create regex from template
    - _Requirements: 4.1, 4.2, 4.3_
  
  - [x] 3.2 Write unit tests for TemplateEngine
    - Test parsing templates with single variable
    - Test parsing templates with multiple variables
    - Test templates with no variables
    - Test malformed templates
    - _Requirements: 4.1, 4.2, 4.3_

- [ ] 4. Implement CLIParser for CLI-style argument parsing
  - [x] 4.1 Create lib/rake_commander/cli_parser.rb
    - Implement initialize method accepting config hash
    - Implement parse method to process ARGV
    - Implement extract_flag_and_template to parse config values
    - Implement match_and_extract to match argv against templates using TemplateEngine
    - Handle quoted values with spaces
    - Return hash with extracted values or nil for missing args
    - _Requirements: 1.1, 1.2, 1.3, 1.4, 1.5, 4.1, 4.4_
  
  - [x] 4.2 Write unit tests for CLIParser
    - Test single flag parsing
    - Test multiple flags in one invocation
    - Test quoted values with spaces
    - Test missing optional arguments
    - Test unknown flags are ignored
    - _Requirements: 1.1, 1.2, 1.3, 1.4, 1.5_

- [ ] 5. Implement BracketParser for bracket-style argument parsing
  - [x] 5.1 Create lib/rake_commander/bracket_parser.rb
    - Implement initialize method accepting config hash
    - Implement parse method to process ARGV
    - Implement extract_bracket_args to find [key=value] patterns
    - Implement parse_bracket_value to handle quoted and unquoted values
    - Map bracket keys to config keys
    - Return hash with extracted values
    - _Requirements: 2.2, 2.5_
  
  - [x] 5.2 Write unit tests for BracketParser
    - Test [key=value] parsing
    - Test [key="value with spaces"] parsing
    - Test multiple bracket arguments
    - Test malformed brackets
    - _Requirements: 2.2, 2.5_

- [ ] 6. Implement HelpGenerator for documentation
  - [x] 6.1 Create lib/rake_commander/help_generator.rb
    - Implement initialize accepting config and optional readme_content
    - Implement display_and_exit method
    - Implement generate_help_text to create formatted help from config
    - Implement format_option to format individual argument descriptions
    - Display custom README if provided, otherwise auto-generate from config
    - Call exit(0) after displaying help
    - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5_
  
  - [x] 6.2 Write unit tests for HelpGenerator
    - Test help text generation from config
    - Test custom README display
    - Test formatting of options
    - Mock exit behavior for testing
    - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5_

- [ ] 7. Implement ArgumentParser orchestrator
  - [x] 7.1 Create lib/rake_commander/argument_parser.rb
    - Implement initialize accepting config and notation
    - Implement validate_notation to check for valid notation symbols
    - Implement select_parser to return CLIParser or BracketParser instance
    - Implement parse method to orchestrate parsing workflow
    - Raise InvalidNotationError for unsupported notation
    - _Requirements: 2.1, 2.2, 2.3, 2.4_
  
  - [x] 7.2 Write unit tests for ArgumentParser
    - Test notation validation
    - Test parser selection for :cli and :bracket
    - Test error handling for invalid notation
    - _Requirements: 2.1, 2.2, 2.3, 2.4_

- [x] 8. Implement HashWithIndifferentAccess utility
  - Create lib/rake_commander/hash_with_indifferent_access.rb
  - Implement class that allows both string and symbol key access
  - Override [] method to handle both string and symbol keys
  - Override []= method to store with string keys
  - _Requirements: 5.4_

- [ ] 9. Implement main RakeCommander module API
  - [x] 9.1 Update lib/rake_commander.rb with public API
    - Require all component files
    - Implement command_line_args class method
    - Detect --help flag in ARGV and trigger HelpGenerator if present
    - Create ArgumentParser with config and notation
    - Call parse and wrap result in HashWithIndifferentAccess
    - Implement initialize_readme class method to store readme content
    - Store readme content in class variable for help generation
    - _Requirements: 1.1, 2.1, 2.3, 3.1, 5.1, 5.2, 5.3, 5.4_
  
  - [x] 9.2 Write unit tests for RakeCommander module
    - Test command_line_args with CLI notation
    - Test command_line_args with bracket notation
    - Test --help flag triggers help display
    - Test initialize_readme stores content
    - Test default notation is :cli
    - _Requirements: 1.1, 2.1, 2.3, 3.1, 5.1, 5.2_

- [ ] 10. Create integration tests for end-to-end scenarios
  - [x] 10.1 Write integration tests
    - Test full CLI parsing workflow with multiple arguments
    - Test full bracket parsing workflow
    - Test help display with custom README
    - Test help display with auto-generated content
    - Test mixed scenarios with various argument combinations
    - Test error scenarios and error messages
    - _Requirements: 1.1, 1.2, 1.3, 2.2, 3.2, 5.5_

- [x] 11. Create gem documentation and examples
  - Create README.md with installation instructions
  - Add usage examples for CLI notation
  - Add usage examples for bracket notation
  - Add help documentation setup example
  - Document configuration hash format
  - Add troubleshooting section
  - _Requirements: 6.1, 6.2, 6.5_

- [x] 12. Finalize gem packaging
  - Verify gemspec has all required metadata (version, authors, description, homepage)
  - Add LICENSE file (MIT)
  - Ensure all files are included in gemspec files list
  - Test gem build with `gem build rake_commander.gemspec`
  - Test gem installation locally
  - _Requirements: 6.1, 6.2, 6.3, 6.4, 6.5_
