class ApiHelper
  attr_reader :session_manager
  def initialize(session_manager:)
    @session_manager = session_manager
  end


  def get_variant_info(sku:)
    what = @session_manager.api(path: 'variants',admin:true,data: {q:{sku_cont:sku}},action:'GET' )
    unless what.key? 'variants'
      raise "cannot find varient result in search"
    end

    if what['variants'].count == 0
      raise "No Results Found for Variant"
    end

    if what['variants'].count > 1
      raise "Too Many Results Found for Variant"
    end

    what['variants'][0]
  end

  def give_credit(amount:)
    user_id = @session_manager.user_id
    feedback = @session_manager.post(path: 'users/add_credits',params:{user_id:user_id,amount: amount.to_f})
    if feedback['valid']
      return feedback['total_credit'].to_f
    else
      raise feedback['errors'].to_s
    end
  end

  def buy_item

  end
end