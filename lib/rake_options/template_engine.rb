# frozen_string_literal: true

module RakeOptions
  class TemplateEngine
    # Parse a template string into components
    # @param template [String] Template like "--flag $variable"
    # @return [Hash] Template structure with flag, variables, and pattern
    def self.parse_template(template)
      variables = identify_variables(template)
      pattern = build_pattern(template, variables)
      
      {
        template: template,
        variables: variables,
        pattern: pattern
      }
    end

    # Extract values from input based on template
    # @param input [Array] Input tokens (ARGV)
    # @param parsed_template [Hash] Parsed template structure
    # @return [Hash, nil] Extracted variable values or nil if no match
    def self.extract_values(input, parsed_template)
      input_str = input.join(" ")
      match = parsed_template[:pattern].match(input_str)
      
      return nil unless match

      result = {}
      # Each variable creates 2 capture groups (quoted and unquoted)
      # We need to pick the non-nil one
      capture_index = 1
      parsed_template[:variables].each do |var|
        # Get both possible captures (quoted or unquoted)
        quoted_value = match[capture_index]
        unquoted_value = match[capture_index + 1]
        
        result[var] = quoted_value || unquoted_value
        capture_index += 2
      end
      
      result
    end

    private

    # Find $variable placeholders in template
    # @param template [String] Template string
    # @return [Array<String>] List of variable names
    def self.identify_variables(template)
      template.scan(/\$(\w+)/).flatten
    end

    # Create regex pattern from template
    # @param template [String] Template string
    # @param variables [Array<String>] Variable names
    # @return [Regexp] Regex pattern for matching
    def self.build_pattern(template, variables)
      # Replace $variables with capture groups that match:
      # - Values after = sign: --flag=value
      # Pattern matches: --flag=value or --flag="value with spaces"
      
      # First, escape the template
      pattern_str = Regexp.escape(template)
      
      # Then replace escaped $variable patterns with our capture group
      # The pattern after escaping looks like: \$variable
      pattern_str = pattern_str.gsub(/\\ \\\$\w+/, '=(?:"([^"]+)"|([^\s]+))')
      
      Regexp.new(pattern_str)
    end
  end
end
