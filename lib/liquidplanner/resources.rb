#
# Copyright 2009 LiquidPlanner, Inc.
#
module LiquidPlanner
  module Resources

    # account and workspaces change rarely,
    # so memoize them on first access
    #
    def account
      @account ||= _account.get.from_json.freeze
    end
        
    def workspaces
      @workspaces ||= _workspaces.get.from_json.freeze
    end
    
    def chatter( options = {} )

      options.assert_valid_keys( :limit, :for_me, :ignore_mine, :start_date, :end_date )
      now = Time.now
      params = {
        :limit       => 10,
        :for_me      => false,
        :ignore_mine => false,
        :start_date  => ( now - ( 7 * 86400 ) ).to_iso8601,
        :end_date    => ( now                 ).to_iso8601,
      }.merge( options )

      _chatter[ "?#{params.to_url_params}" ].get.from_json

    end

    def tasks(params={})
      _tasks["?#{params.to_url_params}"].get.from_json
    end

    def folders(params={})
      _folders["?#{params.to_url_params}"].get.from_json
    end

    def projects(params={})
      _projects["?#{params.to_url_params}"].get.from_json
    end

    def clients(params={})
      _clients["?#{params.to_url_params}"].get.from_json
    end

    def tasklists(params={})
      _tasklists["?#{params.to_url_params}"].get.from_json
    end

    def members
      _members.get.from_json
    end

    def my_tasks( limit = 10, include_done = false, include_on_hold = false )

      filter = []
      filter << "owner_id = #{account['id']}"
      filter << "is_done is false" unless include_done
      filter << "on_hold is false" unless include_on_hold

      params = {
        :filter => filter,
        :limit  => limit
      }

      _tasks[ "?#{params.to_url_params}" ].get.from_json

    end

    def track_time( task, options = {} )
      id = task["id"]

      params = {}
      params[:work_performed_on] = ( options[:work_performed_on] || Time.now                     ).to_iso8601
      params[:work]              = ( options[:work]              || 0                            ).to_i
      params[:low]               = ( options[:low]               || task[:low_effort_remaining]  ) 
      params[:high]              = ( options[:high]              || task[:high_effort_remaining] ) 
      params[:activity_id]       = ( options[:activity_id]       || 0                            ).to_i
      params[:comment]           = options[:comment] if options.has_key?(:comment)
      params[:is_done]           = options[:is_done] if options.has_key?(:is_done)
      params[:done_on]           = options[:done_on] if options.has_key?(:done_on)

      _tasks["/#{id}/track_time"].post params
    end

    def _account
      restclient['/account']
    end

    def _workspaces
      restclient['/workspaces']
    end

    def _chatter
      restclient["/workspaces/#{workspace_id}/chatter"]
    end

    def _members
      restclient["/workspaces/#{workspace_id}/members"]
    end

    def _tasks
      restclient["/workspaces/#{workspace_id}/tasks"]
    end

    def _tasklists
      restclient["/workspaces/#{workspace_id}/tasklists"]
    end
    
    def _folders
      restclient["/workspaces/#{workspace_id}/folders"]
    end

    def _projects
      restclient["/workspaces/#{workspace_id}/projects"]
    end

    def _clients
      restclient["/workspaces/#{workspace_id}/clients"]
    end

  end
end
