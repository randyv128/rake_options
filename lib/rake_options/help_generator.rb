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

    # Normalize config to hash format
    # @param config [Array, Hash] Configuration
    # @return [Hash] Normalized configuration
    def normalize_config(config)
      if config.is_a?(Array)
        config.to_h
      else
        config
      end
    end

    # Auto-generate help from config
    # @return [String] Auto-generated help text
    def auto_generate_help
      help_text = "Available Options:\n\n"
      
      @config.each do |key, type|
        help_text += format_option(key, type)
      end
      
      help_text
    end

    # Format individual option for display
    # @param key [String] Option key
    # @param type [Symbol] Value type
    # @return [String] Formatted option line
    def format_option(key, type)
      "  --#{key}=VALUE".ljust(42) + "(#{type})\n"
    end
  end
end
