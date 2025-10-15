# frozen_string_literal: true

require "spec_helper"
require "rake_options/template_engine"

RSpec.describe RakeOptions::TemplateEngine do
  describe ".parse_template" do
    context "with single variable" do
      it "parses template with one variable" do
        result = described_class.parse_template("--with-mysql-lib $path")
        
        expect(result[:template]).to eq("--with-mysql-lib $path")
        expect(result[:variables]).to eq(["path"])
        expect(result[:pattern]).to be_a(Regexp)
      end
    end

    context "with multiple variables" do
      it "parses template with multiple variables" do
        result = described_class.parse_template("--config $file --env $environment")
        
        expect(result[:template]).to eq("--config $file --env $environment")
        expect(result[:variables]).to eq(["file", "environment"])
        expect(result[:pattern]).to be_a(Regexp)
      end
    end

    context "with no variables" do
      it "parses template without variables" do
        result = described_class.parse_template("--enable-feature")
        
        expect(result[:template]).to eq("--enable-feature")
        expect(result[:variables]).to eq([])
        expect(result[:pattern]).to be_a(Regexp)
      end
    end
  end

  describe ".extract_values" do
    context "with single variable template" do
      let(:parsed_template) { described_class.parse_template("--with-mysql-lib $path") }

      it "extracts value from matching input" do
        input = ["--with-mysql-lib", "/usr/local/mysql/lib"]
        result = described_class.extract_values(input, parsed_template)
        
        expect(result).to eq({ "path" => "/usr/local/mysql/lib" })
      end

      it "extracts quoted value with spaces" do
        input = ["--with-mysql-lib", '"path with spaces"']
        result = described_class.extract_values(input, parsed_template)
        
        expect(result["path"]).to include("path")
      end

      it "returns nil for non-matching input" do
        input = ["--different-flag", "value"]
        result = described_class.extract_values(input, parsed_template)
        
        expect(result).to be_nil
      end
    end

    context "with multiple variable template" do
      let(:parsed_template) { described_class.parse_template("--config $file --env $environment") }

      it "extracts multiple values from matching input" do
        input = ["--config", "database.yml", "--env", "production"]
        result = described_class.extract_values(input, parsed_template)
        
        expect(result["file"]).to eq("database.yml")
        expect(result["environment"]).to eq("production")
      end
    end
  end

  describe ".identify_variables" do
    it "finds single variable" do
      variables = described_class.send(:identify_variables, "--flag $var")
      expect(variables).to eq(["var"])
    end

    it "finds multiple variables" do
      variables = described_class.send(:identify_variables, "--flag $var1 --other $var2")
      expect(variables).to eq(["var1", "var2"])
    end

    it "returns empty array when no variables" do
      variables = described_class.send(:identify_variables, "--flag value")
      expect(variables).to eq([])
    end
  end

  describe ".build_pattern" do
    it "creates pattern for single variable" do
      variables = ["path"]
      pattern = described_class.send(:build_pattern, "--with-mysql-lib $path", variables)
      
      expect(pattern).to be_a(Regexp)
      expect("--with-mysql-lib /usr/local/lib").to match(pattern)
    end

    it "creates pattern for multiple variables" do
      variables = ["file", "env"]
      pattern = described_class.send(:build_pattern, "--config $file --env $env", variables)
      
      expect(pattern).to be_a(Regexp)
      expect("--config db.yml --env prod").to match(pattern)
    end
  end
end
