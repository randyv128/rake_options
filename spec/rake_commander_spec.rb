# frozen_string_literal: true

require "spec_helper"

RSpec.describe RakeCommander do
  let(:config) do
    {
      "with-mysql-lib" => "--with-mysql-lib $path",
      "enable-feature" => "--enable-feature $name"
    }
  end

  describe ".command_line_args" do
    context "with CLI notation" do
      it "parses CLI-style arguments" do
        stub_const("ARGV", ["--with-mysql-lib", "/usr/local/lib"])
        result = described_class.command_line_args(config, notation: :cli)
        
        expect(result["with-mysql-lib"]).to eq("/usr/local/lib")
      end

      it "supports symbol key access" do
        stub_const("ARGV", ["--with-mysql-lib", "/usr/local/lib"])
        result = described_class.command_line_args(config, notation: :cli)
        
        expect(result[:with_mysql_lib]).to eq("/usr/local/lib")
      end
    end

    context "with bracket notation" do
      it "parses bracket-style arguments" do
        stub_const("ARGV", ["[with-mysql-lib=/usr/local/lib]"])
        result = described_class.command_line_args(config, notation: :bracket)
        
        expect(result["with-mysql-lib"]).to eq("/usr/local/lib")
      end
    end

    context "with default notation" do
      it "defaults to CLI notation" do
        stub_const("ARGV", ["--with-mysql-lib", "/usr/local/lib"])
        result = described_class.command_line_args(config)
        
        expect(result["with-mysql-lib"]).to eq("/usr/local/lib")
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
        stub_const("ARGV", ["--with-mysql-lib", "/usr/local/lib"])
        result = described_class.command_line_args(config)
        
        expect(result).to be_a(RakeCommander::HashWithIndifferentAccess)
      end
    end
  end

  describe ".initialize_readme" do
    it "stores readme content" do
      readme = "Custom help text"
      described_class.initialize_readme(readme)
      
      expect(described_class.readme_content).to eq(readme)
    end

    it "uses stored readme in help display" do
      readme = "My Custom Help"
      described_class.initialize_readme(readme)
      stub_const("ARGV", ["--help"])
      
      expect { described_class.command_line_args(config) }
        .to output(/My Custom Help/).to_stdout
        .and raise_error(SystemExit)
    end
  end
end
