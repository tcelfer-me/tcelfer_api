# frozen_string_literal: true

require 'date'
require 'logger'
require 'rack'
require 'rack/contrib'
require 'rack/cors'
require 'sequel'
require 'yaml'

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'tcelfer_api/utils'
# This is easier than the utils class counting up the lib/ tree.
TcelferApi::Utils.app_root = File.expand_path(__dir__)

# Timezones are hard, mannnn ~agargiulo
Sequel.datetime_class = DateTime
Sequel.application_timezone = :local

# Connect to the database plz
DB = Sequel.postgres(TcelferApi.config[:db_conf])
DB.loggers << Logger.new($stderr) if ENV['RACK_ENV'] == 'development'

# Run migrations always on start.
Sequel.extension :migration
Sequel::Migrator.run(DB, File.expand_path('db/migrations', __dir__))

# Load the Sequel::Models in
require_relative 'models/rating'
require_relative 'models/user'
require_relative 'models/auth_token'
require_relative 'models/day'

# Pre-seed `ratings` table if the defaults are missing
TcelferApi::Utils.seed_ratings_table!

use Rack::Cors, :debug => true, :logger => Logger.new(STDOUT) do
  allow do
    origins 'http://localhost:8080'
    resource '/api/v1/*',
             headers: :any,
             methods: :any
  end
end
# Load in the controllers
require_relative 'controllers/tcelfer_api'
require_relative 'controllers/user_management'

# Maybe this will work for a more public route
map('/api/v1/user') { run TcelferApi::UserManagement }
# Configure the root paths for the controllers
map('/api/v1') { run TcelferApi::TcelferApiApp }
map('/*') { run Rack::NotFound.new }
