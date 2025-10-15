# frozen_string_literal: true

require "spec_helper"
require "rake_options/cli_parser"

RSpec.describe RakeOptions::CLIParser do
  describe "#parse" do
    context "with single flag" do
      let(:config) do
        {
          "with-mysql-lib" => "--with-mysql-lib $path"
        }
      end
      let(:parser) { described_class.new(config) }

      it "parses single flag with value" do
        argv = ["--with-mysql-lib=/usr/local/mysql/lib"]
        result = parser.parse(argv)
        
        expect(result["with-mysql-lib"]).to eq("/usr/local/mysql/lib")
      end

      it "returns nil for missing argument" do
        argv = []
        result = parser.parse(argv)
        
        expect(result["with-mysql-lib"]).to be_nil
      end
    end

    context "with multiple flags" do
      let(:config) do
        {
          "with-mysql-lib" => "--with-mysql-lib $path",
          "enable-feature" => "--enable-feature $name"
        }
      end
      let(:parser) { described_class.new(config) }

      it "parses multiple flags in one invocation" do
        argv = ["--with-mysql-lib=/usr/local/lib", "--enable-feature=caching"]
        result = parser.parse(argv)
        
        expect(result["with-mysql-lib"]).to eq("/usr/local/lib")
        expect(result["enable-feature"]).to eq("caching")
      end

      it "handles partial arguments" do
        argv = ["--with-mysql-lib=/usr/local/lib"]
        result = parser.parse(argv)
        
        expect(result["with-mysql-lib"]).to eq("/usr/local/lib")
        expect(result["enable-feature"]).to be_nil
      end
    end

    context "with quoted values" do
      let(:config) do
        {
          "message" => "--message $text"
        }
      end
      let(:parser) { described_class.new(config) }

      it "handles quoted values with spaces" do
        argv = ['--message="Hello World"']
        result = parser.parse(argv)
        
        expect(result["message"]).to eq("Hello World")
      end
    end

    context "with unknown flags" do
      let(:config) do
        {
          "known-flag" => "--known-flag $value"
        }
      end
      let(:parser) { described_class.new(config) }

      it "ignores unknown flags without raising errors" do
        argv = ["--unknown-flag=value", "--known-flag=test"]
        
        expect { parser.parse(argv) }.not_to raise_error
        result = parser.parse(argv)
        expect(result["known-flag"]).to eq("test")
      end
    end

    context "with multiple variables in template" do
      let(:config) do
        {
          "database" => "--config $file --env $environment"
        }
      end
      let(:parser) { described_class.new(config) }

      it "extracts multiple variables" do
        argv = ["--config=database.yml", "--env=production"]
        result = parser.parse(argv)
        
        expect(result["database"]).to be_a(Hash)
        expect(result["database"]["file"]).to eq("database.yml")
        expect(result["database"]["environment"]).to eq("production")
      end
    end
  end
end
