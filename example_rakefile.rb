# Example Rakefile demonstrating RakeOptions usage

require 'rake_options'

desc "Build with custom options"
task :build do
  config = [
    ["with-mysql-lib", :string],
    ["enable-feature", :string],
    ["prefix", :string],
    ["port", :integer]
  ]
  
  options = RakeOptions.command_line_args(config)
  
  puts "Build Configuration:"
  puts "  MySQL lib: #{options['with-mysql-lib'] || 'not specified'}"
  puts "  Feature: #{options['enable-feature'] || 'not specified'}"
  puts "  Prefix: #{options['prefix'] || 'not specified'}"
  puts "  Port: #{options['port'] || 'not specified'}"
end

desc "Deploy with environment settings"
task :deploy do
  config = [
    ["environment", :string],
    ["region", :string],
    ["dry-run", :boolean]
  ]
  
  # Initialize help documentation
  RakeOptions.initialize_readme(<<~HELP)
    Deploy Task
    
    Usage: rake deploy -- --environment=ENV --region=REGION [--dry-run=BOOL]
    
    Options:
      --environment=ENV    Target environment (production, staging, development)
      --region=REGION      AWS region (us-east-1, us-west-2, etc.)
      --dry-run=BOOL       Dry run mode (true/false)
  HELP
  
  options = RakeOptions.command_line_args(config)
  
  mode = options[:dry_run] ? "(DRY RUN)" : ""
  puts "Deploying to #{options[:environment]} in #{options[:region]} #{mode}"
end

# Example usage:
# rake build -- --with-mysql-lib=/usr/local/mysql/lib --enable-feature=caching --port=3000
# rake build -- --prefix="/opt/my app"
# rake deploy -- --environment=production --region=us-east-1
# rake deploy -- --environment=staging --region=us-west-2 --dry-run=true
# rake deploy -- --help
