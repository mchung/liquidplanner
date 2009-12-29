#
# Copyright 2009 LiquidPlanner, Inc.
#

module LiquidPlanner

  CLIENT_VERSION = "0.1"
  API_VERSION    = "1.0.0"
  API_HOST       = "app.liquidplanner.com"
  API_BASE_URL   = "https://#{API_HOST}/api"
  
end

require "rubygems"
require "activesupport"
require "restclient"
require "json"
Dir.glob(File.join(File.dirname(__FILE__), 'ext/**/*.rb')).each {|ext| require ext }
require "liquidplanner/api_client"

