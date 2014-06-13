# Load the rails application
require_relative 'application'

# Initialize the rails application
Diaspora::Application.initialize!

require 'oauth/request_proxy/rack_request'

OAUTH_10_SUPPORT = true
