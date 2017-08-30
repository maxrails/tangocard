class TangoCardV2::ExchangeRate < TangoCardV2::Base
  attr_reader :currency_code, :rate

  # Return current currency exchange rate timestamp.
  #
  # Example:
  #   >> TangoCardV2::ExchangeRate.timestamp
  #    => 1456956187
  #
  # Arguments:
  #   none
  def self.timestamp
    TangoCardV2::Raas.rewards_index.parsed_response['xrates']['timestamp']
  end

  # Return an array of all currency exchange rates.
  #
  # Example:
  #   >> TangoCardV2::ExchangeRate.all
  #    => [#<TangoCardV2::ExchangeRate:0x007ff31ab927a0 @currency_code="USD", @rate="1.00000">,
  #        #<TangoCardV2::ExchangeRate:0x007ff31ab92750 @currency_code="JPY", @rate="123.44700">, ...]
  #
  # Arguments:
  #   none
  def self.all
    TangoCardV2::Raas.rewards_index.parsed_response['xrates']['rates'].map do |currency_code, rate|
      TangoCardV2::ExchangeRate.new(currency_code, rate)
    end
  end

  # Find a exchange rate by its currency code.
  #
  # Example:
  #   >> TangoCardV2::ExchangeRate.find("EUR")
  #    => #<TangoCardV2::ExchangeRate:0x007ff31a2dd808 @currency_code="EUR", @rate="0.88870">
  #
  # Arguments:
  #   currency_code: (String)
  def self.find(currency_code)
    self.all.select{|r| r.currency_code == currency_code}.first
  end

  # Set all available exchange rates for Money gem. Once set allows to get reward USD representation
  # of other currencies. For more information and use cases refer to Money gem docs.
  #
  # Example:
  #   >> TangoCardV2::ExchangeRate.populate_money_rates
  #    => true
  #   >> reward.to_money(:denomination)
  #    => #<Money fractional:500 currency:EUR>
  #   >> reward.to_money(:denomination).exchange_to('USD')
  #    => #<Money fractional:563 currency:USD>
  #
  # Arguments:
  #   none
  def self.populate_money_rates
    self.all.each {|r| Money.add_rate(r.currency_code, 'USD', r.inverse_rate)}
    true
  end

  def initialize(currency_code, rate)
    @currency_code = currency_code
    @rate = rate.to_f
  end

  # Return an inverse rate of original (float). Used to pupulate Money gem rates.
  #
  # Arguments:
  #   none
  def inverse_rate
    1.0 / rate
  end

end
