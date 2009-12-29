#
# Copyright 2009 LiquidPlanner, Inc.
#
require File.join(File.dirname(__FILE__), 'resources.rb')
require "yaml"
require "optparse"

module LiquidPlanner
  class APIClient

    CLIENT_DOTFILE = '.lpclient'

    HEADERS = { :user_agent    => "#{to_s}/#{CLIENT_VERSION}",
                :accept        => 'application/json',
                :x_api_version => API_VERSION
              }.freeze

    attr_accessor :restclient
    
    def initialize( email, password, options={} )
      options.assert_valid_keys(:headers, :api_base_url, :workspace_id)
      headers      = options[:headers] || {}
      api_base_url = options[:api_base_url] || API_BASE_URL
      raise( ArgumentError, "Invalid URL: #{api_base_url}" ) unless api_base_url =~ %r{^https?://[^/]+/api$}
      headers.merge!( HEADERS )
      self.restclient = RestClient::Resource.new( api_base_url,
                                                  :user     => email,
                                                  :password => password,
                                                  :headers  => HEADERS
                                                )
      if options[:workspace_id]
        self.workspace_id = options[:workspace_id]
      else
        select_workspace(workspaces.first)
      end
    end

    def self.new_from_args( args = ARGV )
      dotfile = File.join( ENV['HOME'], CLIENT_DOTFILE )

      opts = OptionParser.new do |opts|
        opts.on("-d", "--dotfile [DOTFILE]") { |path| dotfile = path }
        opts.parse!(ARGV)
      end

      config = YAML.load( File.read( dotfile ) )

      # email:        required
      # password:     required
      # api_base_url: optional, override 

      email        = config["email"]        || raise( "Config #{dotfile} must contain your email"    )
      password     = config["password"]     || raise( "Config #{dotfile} must contain your password" )
      api_base_url = config["api_base_url"] || LiquidPlanner::API_BASE_URL

      new( email, password, :api_base_url => api_base_url )
    end

    def [](*args)
      restclient[*args]
    end

    def workspace_id
      @workspace_id
    end

    def workspace_id=(id)
      id = id.to_i
      unless workspace = workspaces.find {|ws| ws['id'] == id}
        raise ArgumentError, "Invalid workspace id #{id}"
      end
      @selected_workspace = workspace
      @workspace_id       = id
    end

    def select_workspace( workspace_or_id )
      id = case workspace_or_id
           when Hash   then workspace_or_id['id']
           when Fixnum then workspace_or_id
           when String then workspace_or_id
           else             raise ArgumentError
           end
      self.workspace_id = id
    end

    def selected_workspace
      @selected_workspace
    end

    include LiquidPlanner::Resources

    def to_s
      "<%s (account: '%s', workspace: '%s')>" % [ self.class, account['email'], selected_workspace['name'] ]
    end

  end
end
