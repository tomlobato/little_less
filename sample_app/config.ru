
# Bugsnag

require "bugsnag"

Bugsnag.configure do |config|
  config.api_key = "TODO: fill it with your api key"
  config.project_root = '/var/www/yoursite'
end

use Bugsnag::Rack

# Timeout

#require "rack-timeout"
#use Rack::Timeout, service_timeout: 10

# Run

class AlittleLessApp < AlittleLess; end
run AlittleLessApp.rack_app
