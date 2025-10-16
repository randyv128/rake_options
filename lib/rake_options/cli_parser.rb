# frozen_string_literal: true

require_relative "template_engine"

module RakeOptions
  class CLIParser
    def initialize(config)
      @config = normalize_config(config)
      @parsed_templates = {}
      
      # Pre-parse all templates
      @config.each do |key, type, requirement, description|
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
      missing_required = []
      
      @config.each do |key, type, requirement, description|
        parsed_template = @parsed_templates[key]
        extracted = TemplateEngine.extract_values(argv, parsed_template)
        
        if extracted && !extracted.empty?
          raw_value = extracted.values.first
          result[key] = cast_value(raw_value, type)
        else
          result[key] = nil
          # Track missing required arguments
          if requirement == :required
            missing_required << key
          end
        end
      end
      
      # Raise error if required arguments are missing
      unless missing_required.empty?
        raise ArgumentError, "Missing required arguments: #{missing_required.join(', ')}"
      end
      
      result
    end

    private

    # Normalize config format
    # @param config [Array] Configuration array
    # @return [Array] Normalized configuration
    def normalize_config(config)
      config.map do |item|
        case item.length
        when 2
          # [name, type] -> [name, type, :optional, nil]
          [item[0], item[1], :optional, nil]
        when 3
          # [name, type, requirement] -> [name, type, requirement, nil]
          [item[0], item[1], item[2], nil]
        when 4
          # [name, type, requirement, description] -> as is
          item
        else
          raise ArgumentError, "Invalid config format: #{item.inspect}"
        end
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
