#
# Copyright 2009 LiquidPlanner, Inc.
#
class String
  def from_json
    JSON.parse( self )
  end
end
