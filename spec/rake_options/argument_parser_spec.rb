# frozen_string_literal: true

require "spec_helper"
require "rake_options/argument_parser"

RSpec.describe RakeOptions::ArgumentParser do
  let(:config) do
    {
      "option1" => "--option1 $value"
    }
  end

  describe "#initialize" do
    context "with valid notation" do
      it "accepts :cli notation" do
        expect { described_class.new(config, :cli) }.not_to raise_error
      end

      it "accepts :bracket notation" do
        expect { described_class.new(config, :bracket) }.not_to raise_error
      end
    end

    context "with invalid notation" do
      it "raises InvalidNotationError" do
        expect { described_class.new(config, :invalid) }.to raise_error(RakeOptions::InvalidNotationError)
      end

      it "provides helpful error message" do
        expect { described_class.new(config, :invalid) }.to raise_error(
          RakeOptions::InvalidNotationError,
          /Invalid notation ':invalid'. Supported notations: :cli, :bracket/
        )
      end
    end
  end

  describe "#parse" do
    context "with CLI notation" do
      let(:parser) { described_class.new(config, :cli) }

      it "uses CLIParser" do
        expect(RakeOptions::CLIParser).to receive(:new).with(config).and_call_original
        parser.parse
      end
    end

    context "with bracket notation" do
      let(:parser) { described_class.new(config, :bracket) }

      it "uses BracketParser" do
        expect(RakeOptions::BracketParser).to receive(:new).with(config).and_call_original
        parser.parse
      end
    end
  end

  describe "#select_parser" do
    it "returns CLIParser for :cli notation" do
      parser = described_class.new(config, :cli)
      selected = parser.send(:select_parser)
      expect(selected).to be_a(RakeOptions::CLIParser)
    end

    it "returns BracketParser for :bracket notation" do
      parser = described_class.new(config, :bracket)
      selected = parser.send(:select_parser)
      expect(selected).to be_a(RakeOptions::BracketParser)
    end
  end
end
