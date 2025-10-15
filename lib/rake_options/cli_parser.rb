# frozen_string_literal: true

require_relative "template_engine"

module RakeOptions
  class CLIParser
    def initialize(config)
      @config = normalize_config(config)
      @parsed_templates = {}
      
      # Pre-parse all templates
      @config.each do |key, type|
        # Auto-construct the full template from the key
        full_template = "--#{key} $value"
        @parsed_templates[key] = TemplateEngine.parse_template(full_template)
      end
    end

    # Parse CLI-style arguments from ARGV
    # @param argv [Array] Command line arguments (defaults to ARGV)
    # @return [Hash] Parsed values
    def parse(argv = ARGV)
      result = {}
      
      @config.each do |key, type|
        parsed_template = @parsed_templates[key]
        extracted = TemplateEngine.extract_values(argv, parsed_template)
        
        if extracted && !extracted.empty?
          raw_value = extracted.values.first
          result[key] = cast_value(raw_value, type)
        else
          result[key] = nil
        end
      end
      
      result
    end

    private

    # Normalize config to hash format
    # @param config [Array, Hash] Configuration
    # @return [Hash] Normalized configuration
    def normalize_config(config)
      if config.is_a?(Array)
        # Convert array of tuples to hash
        config.to_h
      else
        config
      end
    end

    # Cast value to specified type
    # @param value [String] Raw string value
    # @param type [Symbol] Target type
    # @return [Object] Casted value
    def cast_value(value, type)
      return nil if value.nil?

      case type
      when :string
        value.to_s
      when :integer, :int
        value.to_i
      when :float
        value.to_f
      when :boolean, :bool
        value.downcase == 'true' || value == '1'
      else
        value
      end
    end
  end
end
