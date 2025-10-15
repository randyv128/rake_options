# frozen_string_literal: true

module RakeCommander
  class Error < StandardError; end
  class InvalidNotationError < Error; end
  class TemplateParseError < Error; end
  class ArgumentParseError < Error; end
end
