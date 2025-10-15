# frozen_string_literal: true

module RakeCommander
  class BracketParser
    def initialize(config)
      @config = config
    end

    # Parse bracket-style arguments from ARGV
    # @param argv [Array] Command line arguments (defaults to ARGV)
    # @return [Hash] Parsed values
    def parse(argv = ARGV)
      result = {}
      
      # Extract all bracket arguments from argv
      bracket_args = extract_bracket_args(argv)
      
      # Match bracket args to config keys
      @config.each do |key, _template|
        # Look for matching bracket key
        if bracket_args.key?(key)
          result[key] = bracket_args[key]
        else
          result[key] = nil
        end
      end
      
      result
    end

    private

    # Find all [key=value] patterns in argv
    # @param argv [Array] Command line arguments
    # @return [Hash] Extracted key-value pairs
    def extract_bracket_args(argv)
      result = {}
      
      argv.each do |arg|
        # Match [key=value] or [key="value"]
        match = arg.match(/^\[([^=]+)=(.+)\]$/)
        next unless match
        
        key = match[1]
        value = parse_bracket_value(match[2])
        result[key] = value
      end
      
      result
    end

    # Handle quoted and unquoted values in brackets
    # @param value [String] Value from bracket
    # @return [String] Parsed value
    def parse_bracket_value(value)
      # Remove surrounding quotes if present
      if value.start_with?('"') && value.end_with?('"')
        value[1..-2]
      else
        value
      end
    end
  end
end
