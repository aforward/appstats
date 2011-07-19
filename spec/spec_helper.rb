# This file is copied to spec/ when you run 'rails generate rspec:install'
require 'rubygems'
require 'rspec'
require File.dirname(__FILE__) + '/../lib/appstats'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
# Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

RSpec.configure do |config|

  all_db_configs = YAML::load(File.open('db/config.yml'))
  
  all_db_configs.each do |key,db_config|
    ActiveRecord::Base.configurations[key] = db_config
  end
  
  ActiveRecord::Base.establish_connection(all_db_configs['test'])

  # == Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr
  config.mock_with :rspec
  # config.before(:each) { Machinist.reset_before_test }
  
  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  # config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  # config.use_transactional_fixtures = true

end
