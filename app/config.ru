# This file is used by Rack-based servers to start the application.
#Context
#map Rails::Application.config.relative_url_root || "/" do
#  run Rails.Application
#end
#Context

require_relative 'config/environment'

run Rails.application
