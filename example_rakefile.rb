# Example Rakefile demonstrating RakeOptions usage

require 'rake_options'

desc "Build with custom options"
task :build do
  RakeOptions.initialize_readme_summary(<<~SUMMARY)
    Build Task - Compile and configure the application
    
    Usage: rake build -- [options]
  SUMMARY

  config = [
    ["with-mysql-lib", :string, :required, "Path to MySQL library"],
    ["enable-feature", :string, :optional, "Feature to enable"],
    ["prefix", :string, :optional, "Installation prefix path"],
    ["port", :integer, :optional, "Port number"]
  ]
  
  options = RakeOptions.command_line_args(config)
  
  puts "Build Configuration:"
  puts "  MySQL lib: #{options['with-mysql-lib']}"
  puts "  Feature: #{options['enable-feature'] || 'not specified'}"
  puts "  Prefix: #{options['prefix'] || '/usr/local'}"
  puts "  Port: #{options['port'] || 3000}"
end

desc "Deploy with environment settings"
task :deploy do
  RakeOptions.initialize_readme_summary(<<~SUMMARY)
    Deploy Task - Deploy application to specified environment
    
    Usage: rake deploy -- [options]
  SUMMARY

  config = [
    ["environment", :string, :required, "Target environment (production, staging, development)"],
    ["region", :string, :required, "AWS region (us-east-1, us-west-2, etc.)"],
    ["dry-run", :boolean, :optional, "Dry run mode - don't actually deploy"]
  ]
  
  options = RakeOptions.command_line_args(config)
  
  mode = options[:dry_run] ? "(DRY RUN)" : ""
  puts "Deploying to #{options[:environment]} in #{options[:region]} #{mode}"
end

# Example usage:
# rake build -- --help
# rake build -- --with-mysql-lib=/usr/local/mysql/lib --enable-feature=caching --port=3000
# rake build -- --with-mysql-lib=/usr/local/mysql/lib --prefix="/opt/my app"
# rake deploy -- --help
# rake deploy -- --environment=production --region=us-east-1
# rake deploy -- --environment=staging --region=us-west-2 --dry-run=true
