class TangoCard::Account < TangoCard::Base
  attr_reader :accountIdentifier,
              :displayName,
              :currencyCode,
              :currentBalance,
              :createdAt,
              :status,
              :contactEmail

  private_class_method :new

  # doesnt work for some reason
  def self.show_all
    response = TangoCard::Raas.show_all_accounts
    puts response
  end

  # Find account given accountIdentifier.
  #
  # Example:
  #   >> TangoCard::Account.find('oneclass')
  #    => #<TangoCard::Account:0x007fc5da3d56b0 @customer="oneclass", @email=nil, @identifier="oneclass", @available_balance=10000.0>
  #    Balance is in dollars. Email is not required in sandbox mode, as a replacement using displayName
  #
  # Arguments:
  #   accountIdentifier: (String)
  def self.find( accountIdentifier )
    response = TangoCard::Raas.show_account( accountIdentifier )
    if response.success?
      new(response.parsed_response)
    else
      raise response.error_message
    end
  end

  #accountCriteria = { contactEmail, displayName, accountIdentifier }

  # "contactEmail"      - An email address for a designated representative for this account.
  # "displayName"       - A friendly name for this account
  # "accountIdentifier" - A unique identifier for this account.
  #                       This identifier must be lowercase if alphabetic characters are used.

  def self.create customerIdentifier, email, displayName, accountIdentifier
    accountCriteria = {
        'contactEmail'      => email,
        'displayName'       => displayName,
        'accountIdentifier' => accountIdentifier
    }
    response = TangoCard::Raas.create_account( customerIdentifier, accountCriteria )
    if response.success?
      puts response.parsed_response
      new(response.parsed_response['account'])
    else
      raise response.error_message
    end
  end

  #createAccountParams = [ customerIdentifier, accountCriteria ]
  def self.find_or_create( accountIdentifier, createAccountParams )
    begin
      find(customer, identifier)
    rescue StandardError => e
      create(customer, identifier, email)
    end
  end

  def initialize(params)
    @displayName        = params['displayName']
    @accountIdentifier  = params['accountIdentifier']
    @contactEmail       = params['contactEmail']
    @available_balance  = params['currentBalance'].to_f # Balance is in dollars, NOT CENTS!!!
  end

  def balance
    @available_balance
  end

  def balance_in_cents
    ( @available_balance * 100 ).to_i
  end

end
