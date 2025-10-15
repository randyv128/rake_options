# frozen_string_literal: true

require_relative "cli_parser"
require_relative "bracket_parser"
require_relative "errors"

module RakeOptions
  class ArgumentParser
    VALID_NOTATIONS = [:cli, :bracket].freeze

    def initialize(config, notation)
      @config = config
      @notation = notation
      validate_notation
    end

    # Parse ARGV and return structured options
    # @return [Hash] Parsed options
    def parse
      parser = select_parser
      parser.parse
    end

    private

    # Select appropriate parser based on notation
    # @return [CLIParser, BracketParser] Parser instance
    def select_parser
      case @notation
      when :cli
        CLIParser.new(@config)
      when :bracket
        BracketParser.new(@config)
      end
    end

    # Validate notation parameter
    # @raise [InvalidNotationError] if notation is invalid
    def validate_notation
      return if VALID_NOTATIONS.include?(@notation)

      raise InvalidNotationError,
            "Invalid notation ':#{@notation}'. Supported notations: #{VALID_NOTATIONS.map { |n| ":#{n}" }.join(', ')}"
    end
  end
end
