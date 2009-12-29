#
# Copyright 2009 LiquidPlanner, Inc.
#
class Time
  def to_iso8601
    utc.strftime "%Y-%m-%dT%H:%M:%SZ"
  end
end

