class String
  def uncapitalize
    self[0, 1].downcase + self[1..-1]
  end
end


#tells if the string is a number or not
class String
  def numeric?
    Float(self) != nil rescue false
  end

  def integer?
    self =~ /\A\d+\z/ ? true : false
  end

  def valid_regex?
    Regexp.compile(self)
    true
  rescue
    false
  end

  def to_boolean
     !!(self =~ /^(true|t|yes|y|1)$/i)
  end

  #stick on a http:// if not http at front of string
  def http_safe
    if self.blank?
      return self
    else
      surl =  self
      unless surl[/\Ahttp:\/\//] || surl[/\Ahttps:\/\//]
        surl = "http://#{surl}"
      end
      return surl
    end
  end

end

# make way to convert to integer
class FalseClass; def to_int; 0 end end
class TrueClass; def to_int; 1 end end

class FalseClass; def to_i; 0 end end
class TrueClass; def to_i; 1 end end


class Hash
  def has_ikey?(tkey)
    self.keys.map { |key| key.upcase }.member? tkey.upcase
  end

  # if a key is a string that is an integer, then the string is cast to an integer. Helpful when reconstituting data from json
  def cast_numeric_keys
    hash = self
    hash.inject({}){|result, (key, value)|
      new_key = case key
                  when String
                    if key.integer?
                      key.to_i
                    else
                      key
                    end
                  else key
                end
      new_value = case value
                    when Hash then value.cast_numeric_keys
                    when Array then value.cast_numeric_keys
                    else value
                  end
      result[new_key] = new_value
      result
    }
  end

  def my_deep_symbolize_keys
    hash = self
    hash.inject({}){|result, (key, value)|
      new_key = (key.to_sym rescue key) || key
      new_value = case value
                    when Hash then value.my_deep_symbolize_keys
                    when Array then value.my_deep_symbolize_keys
                    else value
                  end
      result[new_key] = new_value
      result
    }
  end

  def my_deep_string_keys
    hash = self
    hash.inject({}){|result, (key, value)|
      new_key = (key.to_s rescue key) || key
      new_value = case value
                    when Hash then value.my_deep_string_keys
                    when Array then value.my_deep_string_keys
                    else value
                  end
      result[new_key] = new_value
      result
    }
  end


end

class Array
  def my_deep_symbolize_keys  #this is used with the hash method above
    self.map do |value|
      case value
        when Hash then value.my_deep_symbolize_keys
        when Array then value.my_deep_symbolize_keys
        else value
      end
    end
  end

  def my_deep_string_keys  #this is used with the hash method above
    self.map do |value|
      case value
        when Hash then value.my_deep_string_keys
        when Array then value.my_deep_string_keys
        else value
      end
    end
  end

  def cast_numeric_keys
    self.map do |value|
      case value
        when Hash then value.cast_numeric_keys
        when Array then value.cast_numeric_keys
        else value
      end
    end
  end
end