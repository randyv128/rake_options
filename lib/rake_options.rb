# frozen_string_literal: true

require_relative "rake_options/version"
require_relative "rake_options/errors"
require_relative "rake_options/cli_parser"
require_relative "rake_options/help_generator"
require_relative "rake_options/hash_with_indifferent_access"

module RakeOptions
  class << self
    attr_accessor :readme_content

    # Parse command line arguments based on configuration
    # @param config [Array] Argument configuration as array of [name, type] tuples
    # @return [HashWithIndifferentAccess] Parsed arguments with indifferent access
    def command_line_args(config)
      # Check for --help flag
      if ARGV.include?("--help")
        help_generator = HelpGenerator.new(config, readme_content)
        help_generator.display_and_exit
      end

      # Parse arguments using CLI parser
      parser = CLIParser.new(config)
      result = parser.parse

      # Wrap in HashWithIndifferentAccess
      HashWithIndifferentAccess.new(result)
    end

    # Initialize help summary
    # @param summary [String] Brief summary text for help display
    # @return [void]
    def initialize_readme_summary(summary)
      self.readme_content = summary
    end
  end
end
