class TangoCardV2::Raas
  include HTTParty

  def self.show_all_customers
    TangoCardV2::Response.new( get_request( '/customers' ) )
  end

  def self.show_all_accounts
    TangoCardV2::Response.new( get_request( '/accounts' ) )
  end

  def self.show_customer_accounts customerIdentifier
    TangoCardV2::Response.new( get_request( "/customers/#{customerIdentifier}/accounts" ) )
  end

  # { "customerIdentifier": "string", "displayName": "string" }
  # "customerIdentifier" - an official identifier for this customer.
  # This identifier needs to be lowercase if alphabetic characters are used.
  #
  # "displayName" - a friendly name for this customer

  # for now see this
  #<TangoCardV2::Response:0x007fbd0c6c2638 @parsed_response={"timestamp"=>"2017-08-17T18:24:49.801Z", "requestId"=>"1fd552ba-3e53-48bd-8521-bda213a87b4b", "path"=>"/v2/customers", "httpCode"=>415, "httpPhrase"=>"Unsupported Media Type", "message"=>"Content type 'application/x-www-form-urlencoded;charset=UTF-8' not supported"}, @code=415>
  def self.create_customer params
    TangoCardV2::Response.new(post_request('/customers', { body: params.to_json }))
  end


  # Create a new account. Returns TangoCardV2::Response object.
  def self.create_account customerIdentifier, accountCriteria
    TangoCardV2::Response.new(
      post_request( "/customers/#{customerIdentifier}/accounts", { body: accountCriteria.to_json } )
    )
  end

  # Gets account details. Returns TangoCardV2::Response object.
  #
  # Example:
  #   >> TangoCardV2::Raas.show_account(customerIdentifier)
  #    => #<TangoCardV2::Response:0x007f9a6c4bca68 ...>
  #
  # Arguments:
  #   accountIdentifier - uniq account identifier
  def self.show_account accountIdentifier
    TangoCardV2::Response.new(get_request("/accounts/#{accountIdentifier}"))
  end


  # Gets customer details. Returns TangoCardV2::Response object.
  #
  # Example:
  #   >> TangoCardV2::Raas.show_customer(customerIdentifier)
  #    => #<TangoCardV2::Response:0x007f9a6c4bca68 ...>
  #
  # Arguments:
  #   customerIdentifier - uniq customer identifier
  def self.show_customer customerIdentifier
    TangoCardV2::Response.new(get_request("/customers/#{customerIdentifier}"))
  end



  def self.rewards_index use_cache: true, verbose: false
    if TangoCardV2.configuration.use_cache && use_cache
      cached_response = TangoCardV2.configuration.cache.read("#{TangoCardV2::CACHE_PREFIX}rewards_index")
      raise 'Tangocard cache is not primed. Either configure the gem to run without caching or warm the cache before calling cached endpoints' if cached_response.nil?
      cached_response
    else
      TangoCardV2::Response.new( get_request("/catalogs?verbose=#{verbose}") )
    end
  end


  ######### #######


  # Funds an account. Returns TangoCardV2::Response object.
  #
  # Example:
  #   >> TangoCardV2::Raas.cc_fund_account(params)
  #    => #<TangoCardV2::Response:0x007f9a6c4bca68 ...>
  #
  # Arguments:
  #   params: (Hash - see https://www.tangocard.com/docs/raas-api/#create-cc-fund for details)
  def self.cc_fund_account params
    TangoCardV2::Response.new(post_request('/cc_fund', { body: params.to_json }))
  end

  # Registers a credit card to an account. Returns TangoCardV2::Response object.
  #
  # Example:
  #   >> TangoCardV2::Raas.register_credit_card(params)
  #    => #<TangoCardV2::Response:0x007f9a6c4bca68 ...>
  #
  # Arguments:
  #   params: (Hash - see https://www.tangocard.com/docs/raas-api/#create-cc-registration for details)
  def self.register_credit_card params
    TangoCardV2::Response.new(post_request('/cc_register', { body: params.to_json }))
  end

  # Deletes a credit card from an account. Returns TangoCardV2::Response object.
  #
  # Example:
  #   >> TangoCardV2::Raas.delete_credit_card(params)
  #    => #<TangoCardV2::Response:0x007f9a6c4bca68 ...>
  #
  # Arguments:
  #   params: (Hash - see https://www.tangocard.com/docs/raas-api/#create-cc-un-registration for details)
  def self.delete_credit_card params
    TangoCardV2::Response.new(post_request('/cc_unregister', { body: params.to_json }))
  end

  # Create an order. Returns TangoCardV2::Response object.
  #
  # Example:
  #   >> TangoCardV2::Raas.create_order(params)
  #    => #<TangoCardV2::Response:0x007f9a6c4bca68 ...>
  #
  # Arguments:
  #   params: (Hash - see https://www.tangocard.com/docs/raas-api/#create-order for details)
  def self.create_order params
    TangoCardV2::Response.new( post_request( '/orders', { body: params.to_json } ) )
  end

  # Get order details. Returns TangoCardV2::Response object.
  #
  # Example:
  #   >> TangoCardV2::Raas.show_order(params)
  #    => #<TangoCardV2::Response:0x007f9a6c4bca68 ...>
  #
  # Arguments:
  #   reference_order_id
  def self.show_order reference_order_id
    TangoCardV2::Response.new( get_request( "/orders/#{reference_order_id}" ) )
  end

  # Retrieve a list of historical orders. Returns TangoCardV2::Response object.
  #
  # Example:
  #   >> TangoCardV2::Raas.orders_index
  #    => #<TangoCardV2::Response:0x007f9a6c4bca68 ...>
  def self.orders_index
    TangoCardV2::Response.new(get_request("/orders"))
  end

  private

  def self.basic_auth_param
    { basic_auth: { username: TangoCardV2.configuration.name, password: TangoCardV2.configuration.key } }
  end

  def self.endpoint
    "#{TangoCardV2.configuration.base_uri}/raas/v2"
  end

  def self.get_request path
    get( "#{endpoint}#{path}", basic_auth_param )
  end

  def self.post_request path, params
    unless params[:headers].present?
      params[:headers] = {
                              'Content-Type'  => 'application/json;charset=UTF-8',
                              'Accept'        => 'application/json'
                          }
    end
    post( "#{endpoint}#{path}", basic_auth_param.merge(params) )
  end
end
