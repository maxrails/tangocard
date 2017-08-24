class Tangocard::Order
  attr_reader :order_id,
              :account_identifier,
              :customer,
              :sku,
              :denomination,
              :amount_charged,
              :reward_message,
              :reward_subject,
              :reward_from,
              :delivered_at,
              :recipient,
              :external_id,
              :reward,
              :raw_response

  private_class_method :new

  def self.all(params = {})
    response = Tangocard::Raas.orders_index(params)
    if response.success_code?
      response.parsed_response['orders'].map{|o| new(o)}
    else
      []
    end
  end

  # Find an order by order_id. Raises Tangocard::OrderNotFoundException on failure.
  #
  # Example:
  #   >> Tangocard::Order.find("113-08258652-15")
  #    => #<Tangocard::Order:0x007f9a6e3a90c0 @order_id="113-08258652-15", @account_identifier="ElliottTest", @customer="ElliottTest", @sku="APPL-E-1500-STD", @amount=1500, @reward_message="testing", @reward_subject="RaaS Sandbox Test", @reward_from="Elliott", @delivered_at="2013-08-15T17:42:18+00:00", @recipient={"name"=>"Elliott", "email"=>"elliott@tangocard.com"}, @reward={"token"=>"520d12fa655b54.34581245", "number"=>"1111111111111256"}>
  #
  # Arguments:
  #   order_id: (String)
  def self.find(order_id)
    response = Tangocard::Raas.show_order({'order_id' => order_id})
    if response.success_code?
      new(response.parsed_response['order'], response)
    else
      raise Tangocard::OrderNotFoundException, "#{response.error_message}"
    end
  end

  # Create order
  # "REQUIRED" params
  # "accountIdentifier"   - specify the account this order will be deducted from
  # "amount"              - specify the face value of of the reward. Always required, including for fixed value items.
  # "customerIdentifier"  - specify the customer associated with the order.
  #                         Must be the customer the accountIdentifier is associated with.
  # "utid"                - the unique identifier for the reward you are sending as provided in the Get Catalog call
  # "sendEmail"           - should Tango Card send the email to the recipient?
  # "recipient"           - email - required if sendEmail is true
  # "recipient"           - firstName - required if sendEmail is true (100 character max)
  # "recipient"           - lastName - always optional (100 character max)
  # recepient: { email: 'string', firstName: 'string', lastName: 'string' }

  # "OPTIONAL" params
  # "campaign"            - Optional campaign that may be used to administratively categorize a specific order or,
  #                         if applicable, call a designated campaign email template.
  # "emailSubject"        - Optional. If not specified, a default email subject will be used for the specified reward.
  # "externalRefID"       - Optional. Idempotenent field that can be used for client-side order cross reference and prevent
  #                         accidental order duplication. Will be returned in order response, order details, and order history.
  # "message"             - optional gift message
  # "sender"              - firstName - always optional (100 character max)
  # "sender"              - lastName - always optional (100 character max)
  # "sender"              - email - always optional
  # "notes"               - Optional order notes (up to 150 characters)

  def self.create(params)
    response = Tangocard::Raas.create_order(params)
    if response.success?
      new(response.parsed_response['order'], response)
    else
      raise Tangocard::OrderCreateFailedException, "#{response.error_message} #{response.invalid_inputs}"
    end
  end

  def initialize(params, raw_response = nil)
    @order_id           = params['order_id']
    @account_identifier = params['account_identifier']
    @customer           = params['customer']
    @sku                = params['sku']
    @denomination       = params['denomination'] || {}
    @amount_charged     = params['amount_charged'] || {}
    @reward_message     = params['reward_message']
    @reward_subject     = params['reward_subject']
    @reward_from        = params['reward_from']
    @delivered_at       = params['delivered_at']
    @recipient          = params['recipient'] || {}
    @external_id        = params['external_id']
    @reward             = params['reward'] || {}
    @raw_response       = raw_response
  end

  def reward
    @reward ||= {}
  end

  def identifier
    @account_identifier
  end
end
