#@order.add_store_credit_payments
# # defined /home/will/.rvm/gems/ruby-2.4.2@mls-global/gems/spree_core-3.4.1/app/models/spree/order/store_credit.rb
# used /home/will/.rvm/gems/ruby-2.4.2@mls-global/gems/spree_frontend-3.4.1/app/controllers/spree/checkout_controller.rb
#
# def add_store_credit_payments
#  get the order amount and the outstanding credit amount, if need more credit add difference
#
#   @order.add_store_credit_payments
#
#   # Return to the Payments page if additional payment is needed.
#   if @order.payments.valid.sum(:amount) < @order.total
#     throw exception
#   end
#
# end
#

class SessionManager
  attr_reader :agent , :admin_key, :user_key, :user_name, :user_email, :user_id, :url_root, :post_token

  # @param [Bool] login_for , default false
  def initialize(user_id: nil,env:, login_for:false)
    @agent = Mechanize.new
    who = SpreeStoreTools::get_store_tokens(user_id: user_id,agent:@agent,env: env,login_for:login_for)
    @url_root = who['url_root']
    @admin_key = who['admin_api_key']
    @user_key = who['api_key']
    @user_name = who['name']
    @user_email = who['email']
    @user_id = user_id
    @post_token = who['authenticity_token']
  end


  # @param [String] path
  # @param [Bool] admin
  # @param [Array] data default {}<p>
  #   if this is not empty then path will post, else it will get
  # </p>
  def api(path:,admin:false, action:'GET',data: {} )
    if admin
      key = @admin_key
    else
      key = @user_key
    end
    @agent.request_headers = {'X-Spree-Token' => key}
    url = @url_root + '/en/store/api/v1/' +path

    case action
      when 'GET'
        what = @agent.get url, data,nil, {'Content-Type' => 'application/json'}
      when 'POST'
        what = @agent.post url, data.to_json, {'Content-Type' => 'application/json'}
      when 'PUT'
        what = @agent.put url, data.to_json, {'Content-Type' => 'application/json'}
      when 'DELETE'
        what = @agent.delete url, data, {'Content-Type' => 'application/json'}
      else
        raise "unknown action of: #{action.to_s}"
    end


    #ap what
    who_string = what.body
    if who_string.nil? || who_string.empty?
      who = nil
    else
      who = JSON.parse(who_string)
    end

    if what.code.to_i >= 400
      raise what.code.to_s + ': ' + who.error
    end

    who
  rescue  Mechanize::ResponseCodeError => e
    if e.page.class.to_s == 'Mechanize::File'
      oops = e.page.body
    else
      oops =  e.page.at('h1').text
      oops += "\n" +  e.page.at('h2').text
      oops += "\n" + e.page.at('div').text
    end

    raise 'Response Code:' + e.response_code.to_s + ":\n" + oops
  end

  def post(path:,params:[])
    other = {utf8:"&#x2713;", _method:"post", authenticity_token: @post_token }
    full_params = params.merge(other)
    url = @url_root + '/en/' +path
    what = @agent.post url, full_params.to_json, {'Content-Type' => 'application/json'}
    who_string = what.body
    who = JSON.parse(who_string)
    if what.code.to_i >= 400
      raise who.error
    end

    who
  end



end