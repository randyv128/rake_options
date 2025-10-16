# frozen_string_literal: true

require "spec_helper"

RSpec.describe RakeOptions do
  let(:config) do
    [
      ["with-mysql-lib", :string, :optional, "Path to MySQL library"],
      ["enable-feature", :string, :optional, "Feature to enable"]
    ]
  end

  describe ".command_line_args" do
    context "parsing arguments" do
      it "parses CLI-style arguments" do
        stub_const("ARGV", ["--with-mysql-lib=/usr/local/lib"])
        result = described_class.command_line_args(config)
        
        expect(result["with-mysql-lib"]).to eq("/usr/local/lib")
      end

      it "supports symbol key access" do
        stub_const("ARGV", ["--with-mysql-lib=/usr/local/lib"])
        result = described_class.command_line_args(config)
        
        expect(result[:with_mysql_lib]).to eq("/usr/local/lib")
      end

      it "parses multiple arguments" do
        stub_const("ARGV", ["--with-mysql-lib=/usr/local/lib", "--enable-feature=caching"])
        result = described_class.command_line_args(config)
        
        expect(result["with-mysql-lib"]).to eq("/usr/local/lib")
        expect(result["enable-feature"]).to eq("caching")
      end
    end

    context "with --help flag" do
      it "triggers help display and exits" do
        stub_const("ARGV", ["--help"])
        
        expect { described_class.command_line_args(config) }
          .to output(/Available Options/).to_stdout
          .and raise_error(SystemExit)
      end
    end

    context "return value" do
      it "returns HashWithIndifferentAccess" do
        stub_const("ARGV", ["--with-mysql-lib=/usr/local/lib"])
        result = described_class.command_line_args(config)
        
        expect(result).to be_a(RakeOptions::HashWithIndifferentAccess)
      end
    end
  end

  describe ".initialize_readme_summary" do
    let(:simple_config) do
      [["option", :string, :optional, "An option"]]
    end

    it "stores readme summary" do
      summary = "Custom help summary"
      described_class.initialize_readme_summary(summary)
      
      expect(described_class.readme_content).to eq(summary)
    end

    it "uses stored summary in help display" do
      summary = "My Custom Help Summary"
      described_class.initialize_readme_summary(summary)
      stub_const("ARGV", ["--help"])
      
      expect { described_class.command_line_args(simple_config) }
        .to output(/My Custom Help Summary/).to_stdout
        .and raise_error(SystemExit)
    end
  end
end
