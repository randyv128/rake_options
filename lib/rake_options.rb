# frozen_string_literal: true

require_relative "rake_options/version"
require_relative "rake_options/errors"
require_relative "rake_options/argument_parser"
require_relative "rake_options/help_generator"
require_relative "rake_options/hash_with_indifferent_access"

module RakeOptions
  class << self
    attr_accessor :readme_content

    # Parse command line arguments based on configuration
    # @param config [Hash] Argument configuration mapping
    # @param notation [Symbol] Notation style (:cli or :bracket)
    # @return [HashWithIndifferentAccess] Parsed arguments with indifferent access
    def command_line_args(config, notation: :cli)
      # Check for --help flag
      if ARGV.include?("--help")
        help_generator = HelpGenerator.new(config, readme_content)
        help_generator.display_and_exit
      end

      # Parse arguments
      parser = ArgumentParser.new(config, notation)
      result = parser.parse

      # Wrap in HashWithIndifferentAccess
      HashWithIndifferentAccess.new(result)
    end

    # Initialize help documentation
    # @param readme_content [String] Help text or README content
    # @return [void]
    def initialize_readme(content)
      self.readme_content = content
    end
  end
end
