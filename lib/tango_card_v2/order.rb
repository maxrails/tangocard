class TangoCardV2::Order < TangoCardV2::Base
  attr_reader :referenceOrderID,
              :accountIdentifier,
              :amount,
              :customerIdentifier,
              :recipient,
              :sendEmail,
              :utid,
              :campain,
              :email_subject,
              :externalRefID,
              :message,
              :sender,
              :notes,
              :denomination,
              :rewardName,
              :status,
              :createdAt,
              :id

  private_class_method :new

  def initialize(params)
    @amount = params['amountCharged']
    @id     = params['referenceOrderID']
    attrs_list              = %w{ createdAt status externalRefID referenceOrderID accountIdentifier customerIdentifier
                                  utid rewardName sendEmail }
    attrs_list_with_default = [
                                  [ 'campaign'        , {}  ],
                                  [ 'email_subject'   , {}  ],
                                  [ 'external_ref_id' , {}  ],
                                  [ 'message'         , {}  ],
                                  [ 'sender'          , {}  ],
                                  [ 'notes'           , {}  ],
                                  [ 'denomination'    , {}  ],
                                  [ 'recipient'       , {}  ]
                              ]

    initialize_read_variables( attrs_list, attrs_list_with_default, params)
  end

  def self.show_all
    response = TangoCardV2::Raas.orders_index
    if response.success?
      response.parsed_response.map{|p| new(p)}
    else
      []
    end
  end

  # Find an order by reference_order_id. Raises TangoCardV2::OrderNotFoundException on failure.
  #
  # Example:
  #   >> TangoCardV2::Order.find("113-08258652-15")
  #    => #<TangoCardV2::Order:0x007f9a6e3a90c0 @order_id="113-08258652-15", @account_identifier="ElliottTest", @customer="ElliottTest", @sku="APPL-E-1500-STD", @amount=1500, @reward_message="testing", @reward_subject="RaaS Sandbox Test", @reward_from="Elliott", @delivered_at="2013-08-15T17:42:18+00:00", @recipient={"name"=>"Elliott", "email"=>"elliott@tangocard.com"}, @reward={"token"=>"520d12fa655b54.34581245", "number"=>"1111111111111256"}>
  #
  # Arguments:
  #   reference_order_id: (String)
  def self.find(reference_order_id)
    response = TangoCardV2::Raas.show_order(reference_order_id)
    if response.code == 200
      new(response.parsed_response)
    else
      raise response.error_message
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
  # Example of request 10 fixed iTunes
  #{
  #   'accountIdentifier' =>  'oneclass',
  #   'amount' => '10',
  #   'customerIdentifier' => 'oneclass',
  #   'recipient' => {
  #                     'email' => 'max@oneclass.com',
  #                     'firstName' => 'Max',
  #                     'lastName' => 'K',
  #                  },
  #   'sendEmail' => 'true',
  #   'utid' => 'U355612'
  #}
  def self.create(params)
    response = TangoCardV2::Raas.create_order(params)
    if response.code == 201
      new(response.parsed_response)
    else
      raise response.error_message
    end
  end

end
