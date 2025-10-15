# frozen_string_literal: true

require "spec_helper"

RSpec.describe "RakeOptions Integration Tests" do
  describe "Full CLI parsing workflow" do
    let(:config) do
      [
        ["with-mysql-lib", :string],
        ["enable-feature", :string],
        ["port", :integer]
      ]
    end

    it "parses multiple CLI arguments in one invocation" do
      stub_const("ARGV", ["--with-mysql-lib=/usr/local/lib", "--enable-feature=caching", "--port=3000"])
      
      result = RakeOptions.command_line_args(config, notation: :cli)
      
      expect(result["with-mysql-lib"]).to eq("/usr/local/lib")
      expect(result["enable-feature"]).to eq("caching")
      expect(result["port"]).to eq(3000)
    end

    it "handles partial arguments gracefully" do
      stub_const("ARGV", ["--with-mysql-lib=/usr/local/lib"])
      
      result = RakeOptions.command_line_args(config, notation: :cli)
      
      expect(result["with-mysql-lib"]).to eq("/usr/local/lib")
      expect(result["enable-feature"]).to be_nil
      expect(result["port"]).to be_nil
    end

    it "supports quoted values with spaces" do
      stub_const("ARGV", ['--with-mysql-lib="/path/with spaces/lib"'])
      
      result = RakeOptions.command_line_args(config, notation: :cli)
      
      expect(result["with-mysql-lib"]).to eq("/path/with spaces/lib")
    end

    it "allows symbol key access" do
      stub_const("ARGV", ["--with-mysql-lib=/usr/local/lib"])
      
      result = RakeOptions.command_line_args(config, notation: :cli)
      
      expect(result[:with_mysql_lib]).to eq("/usr/local/lib")
      expect(result["with-mysql-lib"]).to eq("/usr/local/lib")
    end
  end

  describe "Full bracket parsing workflow" do
    let(:config) do
      {
        "environment" => "[environment=$env]",
        "region" => "[region=$reg]",
        "instance-type" => "[instance-type=$type]"
      }
    end

    it "parses multiple bracket arguments" do
      stub_const("ARGV", ["[environment=production]", "[region=us-west-2]", "[instance-type=t2.micro]"])
      
      result = RakeOptions.command_line_args(config, notation: :bracket)
      
      expect(result["environment"]).to eq("production")
      expect(result["region"]).to eq("us-west-2")
      expect(result["instance-type"]).to eq("t2.micro")
    end

    it "handles quoted bracket values" do
      stub_const("ARGV", ['[environment="staging environment"]'])
      
      result = RakeOptions.command_line_args(config, notation: :bracket)
      
      expect(result["environment"]).to eq("staging environment")
    end

    it "supports symbol key access with dashes/underscores" do
      stub_const("ARGV", ["[instance-type=t2.micro]"])
      
      result = RakeOptions.command_line_args(config, notation: :bracket)
      
      expect(result[:instance_type]).to eq("t2.micro")
      expect(result["instance-type"]).to eq("t2.micro")
    end
  end

  describe "Help display integration" do
    let(:config) do
      {
        "option1" => "--option1 $value",
        "option2" => "--option2 $value"
      }
    end

    context "with custom README" do
      before do
        RakeOptions.initialize_readme("Custom Help Documentation\n\nUsage: rake task [options]")
      end

      it "displays custom README and exits" do
        stub_const("ARGV", ["--help"])
        
        expect { RakeOptions.command_line_args(config) }
          .to output(/Custom Help Documentation/).to_stdout
          .and raise_error(SystemExit) { |error| expect(error.status).to eq(0) }
      end
    end

    context "with auto-generated help" do
      before do
        RakeOptions.readme_content = nil
      end

      it "displays auto-generated help and exits" do
        stub_const("ARGV", ["--help"])
        
        expect { RakeOptions.command_line_args(config) }
          .to output(/Available Options/).to_stdout
          .and raise_error(SystemExit) { |error| expect(error.status).to eq(0) }
      end

      it "includes all configured options in help" do
        stub_const("ARGV", ["--help"])
        
        expect { RakeOptions.command_line_args(config) }
          .to output(/--option1/).to_stdout
          .and raise_error(SystemExit)
      end
    end
  end

  describe "Mixed scenarios" do
    let(:config) do
      [
        ["database", :string],
        ["verbose", :string]
      ]
    end

    it "handles multiple arguments" do
      stub_const("ARGV", ["--database=mydb", "--verbose=debug"])
      
      result = RakeOptions.command_line_args(config, notation: :cli)
      
      expect(result["database"]).to eq("mydb")
      expect(result["verbose"]).to eq("debug")
    end

    it "handles empty ARGV" do
      stub_const("ARGV", [])
      
      result = RakeOptions.command_line_args(config, notation: :cli)
      
      expect(result["database"]).to be_nil
      expect(result["verbose"]).to be_nil
    end

    it "ignores unrecognized arguments" do
      stub_const("ARGV", ["--unknown-flag=value", "--verbose=info"])
      
      result = RakeOptions.command_line_args(config, notation: :cli)
      
      expect(result["verbose"]).to eq("info")
      expect(result["database"]).to be_nil
    end
  end

  describe "Error scenarios" do
    let(:config) do
      [["option", :string]]
    end

    it "raises InvalidNotationError for unsupported notation" do
      stub_const("ARGV", ["--option=value"])
      
      expect { RakeOptions.command_line_args(config, notation: :invalid) }
        .to raise_error(RakeOptions::InvalidNotationError, /Invalid notation/)
    end

    it "provides clear error message with supported notations" do
      stub_const("ARGV", ["--option=value"])
      
      expect { RakeOptions.command_line_args(config, notation: :xml) }
        .to raise_error(RakeOptions::InvalidNotationError, /:cli, :bracket/)
    end
  end

  describe "Real-world usage scenarios" do
    context "deployment task" do
      let(:deploy_config) do
        [
          ["environment", :string],
          ["region", :string],
          ["version", :string],
          ["dry-run", :boolean]
        ]
      end

      it "handles typical deployment command" do
        stub_const("ARGV", ["--environment=production", "--region=us-east-1", "--version=v1.2.3"])
        
        result = RakeOptions.command_line_args(deploy_config)
        
        expect(result[:environment]).to eq("production")
        expect(result[:region]).to eq("us-east-1")
        expect(result[:version]).to eq("v1.2.3")
        expect(result[:dry_run]).to be_nil
      end
    end

    context "build task" do
      let(:build_config) do
        [
          ["with-mysql", :string],
          ["with-ssl", :string],
          ["prefix", :string]
        ]
      end

      it "handles build configuration" do
        stub_const("ARGV", [
          "--with-mysql=/usr/local/mysql/lib",
          "--with-ssl=/usr/local/ssl/lib",
          "--prefix=/opt/myapp"
        ])
        
        result = RakeOptions.command_line_args(build_config)
        
        expect(result["with-mysql"]).to eq("/usr/local/mysql/lib")
        expect(result["with-ssl"]).to eq("/usr/local/ssl/lib")
        expect(result["prefix"]).to eq("/opt/myapp")
      end
    end
  end
end
