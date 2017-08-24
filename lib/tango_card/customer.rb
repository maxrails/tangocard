class TangoCard::Customer < TangoCard::Base

  attr_reader :customerIdentifier,
              :displayName

  private_class_method :new

  def initialize params
    attrs_list = %w{ displayName customerIdentifier }
    initialize_read_variables attrs_list, [], params
  end

  # doesnt work for some reason
  def self.show_all
    response = TangoCard::Raas.show_all_customers
    puts response.parsed_response
  end

  # Find customer given customerIdentifier. Raises TangoCard::AccountCustomerNotFoundException on failure.
  #
  # Example:
  #   >> TangoCard::Customer.find('oneclass')
  #    => #<TangoCard::Account:0x007fc5da3d56b0 @customer="oneclass", @email=nil, @identifier="oneclass", @available_balance=10000.0>
  #    Balance is in dollars. Email is not required in sandbox mode, as a replacement using displayName
  #
  # Arguments:
  #   customerIdentifier: (String)
  def self.find customerIdentifier
    response = TangoCard::Raas.show_customer customerIdentifier
    if response.success?
      new(response.parsed_response)
    else
      raise response.error_message
    end
  end


  def self.accounts_for customerIdentifier
    response = TangoCard::Raas.show_customer_accounts customerIdentifier
    begin
      response.parsed_response
    rescue
      raise response.error_message
    end
  end

  def self.create customerIdentifier, displayName
    response = TangoCard::Raas.create_customer( { 'customerIdentifier' => customerIdentifier, 'displayName' => displayName } )
    if response.success?
      puts response.parsed_response
      new(response.parsed_response['account'])
    else
      raise response.error_message
    end
  end


  def self.find_or_create( customerIdentifier, displayName )
    begin
      self.find customerIdentifier
    rescue TangoCard::AccountCustomerNotFoundException => e
      self.create( customerIdentifier, displayName )
    end
  end





end
