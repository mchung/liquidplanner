#
# Cribbed from various sources, either public domain or with permission;
# see in-line comments, below
#
class Hash

  # From ActiveSupport
  def assert_valid_keys(*valid_keys)
    unknown_keys = keys - [valid_keys].flatten
    raise(ArgumentError, "Unknown key(s): #{unknown_keys.join(", ")}") unless unknown_keys.empty?
  end

  # From http://dev.rubyonrails.org/ticket/8288
  def assert_required_keys(*required_keys) 
    missing_keys = [required_keys].flatten - keys 
    raise(ArgumentError, "Missing required key(s): #{missing_keys.join(", ")}") unless missing_keys.empty? 
  end     

  #
  # Copyright 2009 LiquidPlanner, Inc.
  #
  # convert hash to query string, optionally URI encoding the resulting string
  #
  # a key 'k' with an array value serializes to "k[]=...&k[]=..."; all other
  # value types serialize simply with to_s
  #
  def to_url_params(encode = true)
    s = keys.sort {|a,b| a.to_s <=> b.to_s}.map do |k|
      v = fetch(k)
      case v
      when Array then v.map{|e| "#{k}[]=#{e}"}.join('&')
      else            "#{k}=#{v}"
      end
    end.join('&')
    encode ? URI.encode(s) : s
  end 

  def method_missing(method, *args)
    return self[method     ] if self.has_key?( method      )
    return self[method.to_s] if self.has_key?( method.to_s )
    super
  end

end
