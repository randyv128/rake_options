# frozen_string_literal: true

require "spec_helper"
require "rake_options/cli_parser"

RSpec.describe RakeOptions::CLIParser do
  describe "#parse" do
    context "with single flag" do
      let(:config) do
        [["with-mysql-lib", :string]]
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
        [["with-mysql-lib", :string], ["enable-feature", :string]]
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
        [["message", :string]]
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
        [["known-flag", :string]]
      end
      let(:parser) { described_class.new(config) }

      it "ignores unknown flags without raising errors" do
        argv = ["--unknown-flag=value", "--known-flag=test"]
        
        expect { parser.parse(argv) }.not_to raise_error
        result = parser.parse(argv)
        expect(result["known-flag"]).to eq("test")
      end
    end

    context "with type casting" do
      let(:config) do
        [["port", :integer], ["enabled", :boolean], ["ratio", :float]]
      end
      let(:parser) { described_class.new(config) }

      it "casts integer values" do
        argv = ["--port=3000"]
        result = parser.parse(argv)
        
        expect(result["port"]).to eq(3000)
        expect(result["port"]).to be_a(Integer)
      end

      it "casts boolean values" do
        argv = ["--enabled=true"]
        result = parser.parse(argv)
        
        expect(result["enabled"]).to eq(true)
        expect(result["enabled"]).to be_a(TrueClass)
      end

      it "casts float values" do
        argv = ["--ratio=1.5"]
        result = parser.parse(argv)
        
        expect(result["ratio"]).to eq(1.5)
        expect(result["ratio"]).to be_a(Float)
      end
    end
  end
end
