# frozen_string_literal: true

require_relative "template_engine"

module RakeOptions
  class CLIParser
    def initialize(config)
      @config = config
      @parsed_templates = {}
      
      # Pre-parse all templates
      @config.each do |key, template_str|
        @parsed_templates[key] = TemplateEngine.parse_template(template_str)
      end
    end

    # Parse CLI-style arguments from ARGV
    # @param argv [Array] Command line arguments (defaults to ARGV)
    # @return [Hash] Parsed values
    def parse(argv = ARGV)
      result = {}
      
      @config.each do |key, _template_str|
        parsed_template = @parsed_templates[key]
        extracted = TemplateEngine.extract_values(argv, parsed_template)
        
        if extracted && !extracted.empty?
          # For single variable templates, store the value directly
          if extracted.size == 1
            result[key] = extracted.values.first
          else
            # For multiple variables, store the hash
            result[key] = extracted
          end
        else
          result[key] = nil
        end
      end
      
      result
    end
  end
end
