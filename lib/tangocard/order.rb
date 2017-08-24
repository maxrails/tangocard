class Tangocard::Order
  attr_reader :reference_order_id,
              :account_identifier,
              :amount,
              :customer_identifier,
              :recipient,
              :send_email,
              :utid,
              :campain,
              :email_subject,
              :external_ref_id,
              :message,
              :sender,
              :notes

  private_class_method :new

  def initialize(params)
    @reference_order_id  = params['reference_order_id']
    @account_identifier  = params['account_identifier']
    @amount              = params['amount']
    @customer_identifier = params['customer_identifier']
    @recipient           = params['recipient']
    @send_email          = params['send_email']
    @utid                = params['utid']
    @campaign            = params['campaign'] || {}
    @email_subject       = params['email_subject'] || {}
    @external_ref_id     = params['external_ref_id'] || {}
    @message             = params['message'] || {}
    @sender              = params['sender'] || {}
    @notes               = params['notes'] || {}
  end

  def self.show_all
    response = Tangocard::Raas.orders_index
    if response.success?
      response.parsed_response.map{|p| new(p)}
    else
      []
    end
  end

  # Find an order by reference_order_id. Raises Tangocard::OrderNotFoundException on failure.
  #
  # Example:
  #   >> Tangocard::Order.find("113-08258652-15")
  #    => #<Tangocard::Order:0x007f9a6e3a90c0 @order_id="113-08258652-15", @account_identifier="ElliottTest", @customer="ElliottTest", @sku="APPL-E-1500-STD", @amount=1500, @reward_message="testing", @reward_subject="RaaS Sandbox Test", @reward_from="Elliott", @delivered_at="2013-08-15T17:42:18+00:00", @recipient={"name"=>"Elliott", "email"=>"elliott@tangocard.com"}, @reward={"token"=>"520d12fa655b54.34581245", "number"=>"1111111111111256"}>
  #
  # Arguments:
  #   reference_order_id: (String)
  def self.find(reference_order_id)
    response = Tangocard::Raas.show_order(reference_order_id)
    if response.success_code?
      new(response.parsed_response)
    else
      raise Tangocard::OrderNotFoundException, "#{response.error_message}"
    end
  end

  # Create order
  # "REQUIRED" params
  # "accountIdentifier"  - specify the account this order will be deducted from
  # "amount"             - specify the face value of of the reward. Always required, including for fixed value items.
  # "customerIdentifier" - specify the customer associated with the order. Must be the customer the accountIdentifier is associated with.
  #                         Must be the customer the accountIdentifier is associated with.
  # "recipient"          - email - required if sendEmail is true
  # "recipient"          - firstName - required if sendEmail is true (100 character max)
  # "recipient"          - lastName - always optional (100 character max)
  # "sendEmail"          - should Tango Card send the email to the recipient?
  # "utid"               - the unique identifier for the reward you are sending as provided in the Get Catalog call

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
      new(response.parsed_response)
    else
      raise Tangocard::OrderCreateFailedException, "#{response.error_message}"
    end
  end

  def recipient
    @recipient ||= {}
  end

  def identifier
    @account_identifier
  end
end
