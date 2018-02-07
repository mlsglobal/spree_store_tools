require "spree_store_tools/version"
require "spree_store_tools/cli.rb"
require 'spree_store_tools/primitives_patching'

require 'json'


module SpreeStoreTools


  def self.get_store_tokens(user_id:,agent:,env:,login_for:false)

    Figaro.application = Figaro::Application.new(environment: env, path: File.expand_path('../../config/application.yml', __FILE__))
    Figaro.load

    email = ENV["admin_user_email"]
    password = ENV["admin_user_password"]
    root =  ENV["root"]
    url_root = root

    if email.empty? || email.nil?
      raise "Cannot load figaro for this environment [#{env}]"
    end

    login_for_string = ''
    unless user_id.nil? || user_id.to_i == 0
      if login_for
        login_for_string = "&login_for=#{user_id}"
      else
        login_for_string = "&key_of_user=#{user_id}"
      end
    end

    who_thing = agent.get "#{url_root}/en/login_by_command_line?email=#{email}&password=#{password}#{login_for_string}"
    who_string = who_thing.body
    who = JSON.parse(who_string)
    unless who.key? 'valid'
      ap who
      raise "Return not expected"
    end

    unless who['valid']
      raise "Login Failed: " + who['error']
    end

    who['url_root'] = root
    return who
  end

  def self.print_with_format(ret:,format:)
    raise 'format not in text,json, or yaml' unless %w(text json yaml).include?(format)

    case format
      when 'text'
        if ret.kind_of?(Array)
          ap ret
        else
          # if ret is a json string convert it to a ruby hash
          begin
            if ret.is_a? String
              what = JSON.parse(ret)
              ap what
            else
              ap ret
            end


          rescue JSON::ParserError => _
            print ret
          end
        end

      when 'json'
        print JSON.generate ret
      when 'yaml'
        print ret.to_yaml
      else
        raise 'never get here'
    end
  end
end
