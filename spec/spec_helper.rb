$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'rspec'
require 'strikeiron_address_verification'

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

RSpec.configure do |config|
  dev = File.join('config', 'development.yml')
  YAML.load(File.open(dev)).each do |key, value|
    ENV[key.to_s] = value
  end if File.exists?(dev)
end
