# frozen_string_literal: true

module RakeOptions
  class HelpGenerator
    def initialize(config, readme_content = nil)
      @config = normalize_config(config)
      @readme_content = readme_content
    end

    # Display help and exit
    # @return [void]
    def display_and_exit
      puts generate_help_text
      exit(0)
    end

    private

    # Create formatted help text
    # @return [String] Formatted help text
    def generate_help_text
      if @readme_content
        @readme_content
      else
        auto_generate_help
      end
    end

    # Normalize config format
    # @param config [Array] Configuration array
    # @return [Array] Normalized configuration
    def normalize_config(config)
      config.map do |item|
        case item.length
        when 2
          [item[0], item[1], :optional, nil]
        when 3
          [item[0], item[1], item[2], nil]
        when 4
          item
        else
          raise ArgumentError, "Invalid config format: #{item.inspect}"
        end
      end
    end

    # Auto-generate help from config
    # @return [String] Auto-generated help text
    def auto_generate_help
      help_text = "Available Options:\n\n"
      
      @config.each do |key, type, requirement, description|
        help_text += format_option(key, type, requirement, description)
      end
      
      help_text
    end

    # Format individual option for display
    # @param key [String] Option key
    # @param type [Symbol] Value type
    # @param requirement [Symbol] :required or :optional
    # @param description [String, nil] Option description
    # @return [String] Formatted option line
    def format_option(key, type, requirement, description)
      flag = "  --#{key}=VALUE"
      req_marker = requirement == :required ? " [REQUIRED]" : ""
      type_info = "(#{type})"
      
      line = "#{flag.ljust(30)} #{type_info}#{req_marker}"
      
      if description
        line += "\n      #{description}"
      end
      
      line + "\n"
    end
  end
end
