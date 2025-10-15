# frozen_string_literal: true

module RakeCommander
  class HelpGenerator
    def initialize(config, readme_content = nil)
      @config = config
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

    # Auto-generate help from config
    # @return [String] Auto-generated help text
    def auto_generate_help
      help_text = "Available Options:\n\n"
      
      @config.each do |key, template|
        help_text += format_option(key, template)
      end
      
      help_text
    end

    # Format individual option for display
    # @param key [String] Option key
    # @param template [String] Template string
    # @return [String] Formatted option line
    def format_option(key, template)
      "  #{template.ljust(40)} (#{key})\n"
    end
  end
end
