# frozen_string_literal: true

module RakeOptions
  class Error < StandardError; end
  class InvalidNotationError < Error; end
  class TemplateParseError < Error; end
  class ArgumentParseError < Error; end
end
