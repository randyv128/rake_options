# frozen_string_literal: true

require "spec_helper"
require "rake_commander/help_generator"

RSpec.describe RakeCommander::HelpGenerator do
  describe "#display_and_exit" do
    let(:config) do
      {
        "with-mysql-lib" => "--with-mysql-lib $path",
        "enable-feature" => "--enable-feature $name"
      }
    end

    context "with custom README" do
      let(:readme) { "Custom Help Text\n\nUsage instructions here" }
      let(:generator) { described_class.new(config, readme) }

      it "displays custom README content" do
        expect { generator.display_and_exit }.to output(/Custom Help Text/).to_stdout.and raise_error(SystemExit)
      end
    end

    context "without custom README" do
      let(:generator) { described_class.new(config) }

      it "auto-generates help from config" do
        expect { generator.display_and_exit }.to output(/Available Options/).to_stdout.and raise_error(SystemExit)
      end

      it "includes all configured options" do
        expect { generator.display_and_exit }.to output(/--with-mysql-lib/).to_stdout.and raise_error(SystemExit)
      end
    end

    context "exit behavior" do
      let(:generator) { described_class.new(config) }

      it "exits with status 0" do
        expect { generator.display_and_exit }.to raise_error(SystemExit) do |error|
          expect(error.status).to eq(0)
        end
      end
    end
  end

  describe "#generate_help_text" do
    let(:config) do
      {
        "option1" => "--option1 $value",
        "option2" => "--option2 $value"
      }
    end

    context "with custom README" do
      let(:readme) { "My Custom Help" }
      let(:generator) { described_class.new(config, readme) }

      it "returns custom README" do
        help_text = generator.send(:generate_help_text)
        expect(help_text).to eq("My Custom Help")
      end
    end

    context "without custom README" do
      let(:generator) { described_class.new(config) }

      it "generates help from config" do
        help_text = generator.send(:generate_help_text)
        expect(help_text).to include("Available Options")
        expect(help_text).to include("--option1")
        expect(help_text).to include("--option2")
      end
    end
  end

  describe "#format_option" do
    let(:generator) { described_class.new({}) }

    it "formats option with key and template" do
      formatted = generator.send(:format_option, "my-option", "--my-option $value")
      expect(formatted).to include("--my-option $value")
      expect(formatted).to include("my-option")
    end
  end
end
