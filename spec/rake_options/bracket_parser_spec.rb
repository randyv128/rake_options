# frozen_string_literal: true

require "spec_helper"
require "rake_options/bracket_parser"

RSpec.describe RakeOptions::BracketParser do
  describe "#parse" do
    context "with simple key=value" do
      let(:config) do
        {
          "environment" => "[environment=$env]",
          "region" => "[region=$region]"
        }
      end
      let(:parser) { described_class.new(config) }

      it "parses [key=value] format" do
        argv = ["[environment=production]", "[region=us-west-2]"]
        result = parser.parse(argv)
        
        expect(result["environment"]).to eq("production")
        expect(result["region"]).to eq("us-west-2")
      end

      it "returns nil for missing arguments" do
        argv = ["[environment=production]"]
        result = parser.parse(argv)
        
        expect(result["environment"]).to eq("production")
        expect(result["region"]).to be_nil
      end
    end

    context "with quoted values" do
      let(:config) do
        {
          "message" => "[message=$text]"
        }
      end
      let(:parser) { described_class.new(config) }

      it "parses [key=\"value with spaces\"] format" do
        argv = ['[message="Hello World"]']
        result = parser.parse(argv)
        
        expect(result["message"]).to eq("Hello World")
      end
    end

    context "with multiple bracket arguments" do
      let(:config) do
        {
          "env" => "[env=$environment]",
          "region" => "[region=$reg]",
          "instance" => "[instance=$type]"
        }
      end
      let(:parser) { described_class.new(config) }

      it "parses multiple bracket arguments" do
        argv = ["[env=prod]", "[region=us-east-1]", "[instance=t2.micro]"]
        result = parser.parse(argv)
        
        expect(result["env"]).to eq("prod")
        expect(result["region"]).to eq("us-east-1")
        expect(result["instance"]).to eq("t2.micro")
      end
    end

    context "with malformed brackets" do
      let(:config) do
        {
          "valid" => "[valid=$val]"
        }
      end
      let(:parser) { described_class.new(config) }

      it "ignores malformed bracket arguments" do
        argv = ["[valid=test]", "invalid=value", "[missing-bracket"]
        result = parser.parse(argv)
        
        expect(result["valid"]).to eq("test")
      end
    end
  end
end
