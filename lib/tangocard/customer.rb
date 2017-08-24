class Tangocard::Customer

  attr_reader :customerIdentifier,
              :displayName

  private_class_method :new

  def initialize params
    @displayName        = params['displayName']
    @customerIdentifier = params['customerIdentifier']
  end

  # doesnt work for some reason
  def self.show_all
    response = Tangocard::Raas.show_all_customers
    puts response
  end

  # Find customer given customerIdentifier. Raises Tangocard::AccountCustomerNotFoundException on failure.
  #
  # Example:
  #   >> Tangocard::Customer.find('oneclass')
  #    => #<Tangocard::Account:0x007fc5da3d56b0 @customer="oneclass", @email=nil, @identifier="oneclass", @available_balance=10000.0>
  #    Balance is in dollars. Email is not required in sandbox mode, as a replacement using displayName
  #
  # Arguments:
  #   customerIdentifier: (String)
  def self.find customerIdentifier
    response = Tangocard::Raas.show_customer customerIdentifier
    if response.success?
      new(response.parsed_response)
    else
      raise Tangocard::AccountCustomerNotFoundException, "#{response.error_message}"
    end
  end


  def self.accounts_for customerIdentifier
    response = Tangocard::Raas.show_customer_accounts customerIdentifier
    begin
      response.parsed_response
    rescue
      raise Tangocard::AccountCustomerNotFoundException, "#{response.error_message}"
    end
  end

  def self.create customerIdentifier, displayName
    response = Tangocard::Raas.create_customer( { 'customerIdentifier' => customerIdentifier, 'displayName' => displayName } )
    if response.success?
      puts response.parsed_response
      new(response.parsed_response['account'])
    else
      raise Tangocard::AccountCreateFailedException, "#{response.error_message}"
    end
  end


  def self.find_or_create( customerIdentifier, displayName )
    begin
      self.find customerIdentifier
    rescue Tangocard::AccountCustomerNotFoundException => e
      self.create( customerIdentifier, displayName )
    end
  end





end
