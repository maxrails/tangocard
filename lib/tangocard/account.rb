class Tangocard::Account
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
    response = Tangocard::Raas.show_all_accounts
    puts response
  end

  # Find account given accountIdentifier. Raises Tangocard::AccountCustomerNotFoundException on failure.
  #
  # Example:
  #   >> Tangocard::Account.find('oneclass')
  #    => #<Tangocard::Account:0x007fc5da3d56b0 @customer="oneclass", @email=nil, @identifier="oneclass", @available_balance=10000.0>
  #    Balance is in dollars. Email is not required in sandbox mode, as a replacement using displayName
  #
  # Arguments:
  #   accountIdentifier: (String)
  def self.find( accountIdentifier )
    response = Tangocard::Raas.show_account( accountIdentifier )
    if response.success?
      new(response.parsed_response)
    else
      raise Tangocard::AccountCustomerNotFoundException, "#{response.error_message}"
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
    response = Tangocard::Raas.create_account( customerIdentifier, accountCriteria )
    if response.success?
      puts response
      puts response.parsed_response
      #puts response.parsed_response
      #new(response.parsed_response['account'])
    else
      raise Tangocard::AccountCreateFailedException, "#{response.error_message}"
    end
  end

  #createAccountParams = [ customerIdentifier, accountCriteria ]
  def self.find_or_create( accountIdentifier, createAccountParams )
    begin
      find(customer, identifier)
    rescue Tangocard::AccountCustomerNotFoundException => e
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

  # Register a credit card
  # Raises Tango::AccountRegisterCreditCardFailedException on failure.
  # Example:
  #   >> account.register_credit_card('128.128.128.128', Hash (see example below))
  #    => #<Tangocard::Response:0x007f9a6fec0138 ...>
  #
  # Arguments:
  #   client_ip: (String)
  #   credit_card: (Hash) - see
  # https://www.tangocard.com/docs/raas-api/#create-cc-registration for details
  #
  # Credit Card Hash Example:
  #
  #   {
  #       'number' => '4111111111111111',
  #       'expiration' => '2017-01',
  #       'security_code' => '123',
  #       'billing_address' => {
  #           'f_name' => 'Jane',
  #           'l_name' => 'User',
  #           'address' => '123 Main Street',
  #           'city' => 'Anytown',
  #           'state' => 'NY',
  #           'zip' => '11222',
  #           'country' => 'USA',
  #           'email' => 'jane@company.com'
  #       }
  #   }
  def register_credit_card(client_ip, credit_card)
    params = {
        'client_ip' => client_ip,
        'credit_card' => credit_card,
        'customer' => customer,
        'account_identifier' => identifier
    }

    response = Tangocard::Raas.register_credit_card(params)
  end

  # Add funds to the account.
  # Raises Tangocard::AccountFundFailedException on failure.
  # Example:
  #   >> account.cc_fund(5000, '128.128.128.128', '12345678', '123')
  #    => #<Tangocard::Response:0x007f9a6fec0138 ...>

  # Arguments:
  #   amount: (Integer)
  #   client_ip: (String)
  #   cc_token: (String)
  #   security_code: (String)
  # def cc_fund(amount, client_ip, cc_token, security_code)
  #   params = {
  #       'amount' => amount,
  #       'client_ip' => client_ip,
  #       'cc_token' => cc_token,
  #       'customer' => customer,
  #       'account_identifier' => identifier,
  #       'security_code' => security_code
  #   }
  #
  #   response = Tangocard::Raas.cc_fund_account(params)
  # end
  #
  def cc_fund(amount, client_ip, cc_token, security_code)
    params = {
        'amount' => amount,
        'client_ip' => client_ip,
        'cc_token' => cc_token,
        'customer' => customer,
        'account_identifier' => identifier,
        'security_code' => security_code
    }

    Tangocard::Raas.cc_fund_account(params)
  end

  # Delete a credit card from an account
  # Raises Tangocard::AccountDeleteCreditCardFailedException failure.
  # Example:
  #   >> account.delete_credit_card("12345678")
  #    => #<Tangocard::Response:0x007f9a6fec0138 ...>

  # Arguments:
  #   cc_token: (String)
  def delete_credit_card(cc_token)
    params = {
      'cc_token' => cc_token,
      'customer' => customer,
      'account_identifier' => identifier
    }

    Tangocard::Raas.delete_credit_card(params)
  end

end
