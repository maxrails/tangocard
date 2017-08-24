class Tangocard::Reward
  attr_reader :id,
              :rewardName,
              :currencyCode,
              :status,
              :valueType,
              :rewardType,
              :faceValue,
              :minValue,
              :maxValue,
              :createdDate,
              :lastUpdateDate,
              :countries

  # rewardType: [ 'cash equivalent', 'gift card' ]
  # valueType: [ 'VARIABLE_VALUE', 'FIXED_VALUE' ]
  # for "VARIABLE_VALUE": minValue, maxValue
  # for "FIXED_VALUE": faceValue
  # countries: ["US", "AU", "CA", "MX", "DE", "PR", "AE", "IN", "JP", "CN", "IT", "FR", "NZ", "ES", "GU", "BR", "BS", "AR", "SE", "SG", "UK", "DZ", "TR"]

  def initialize(params)
    @id = params['utid']
    %w{ rewardName currencyCode status valueType rewardType faceValue minValue maxValue createdDate lastUpdateDate countries }.each do |param|
      eval "@#{param} = params['#{param}']"
    end
  end

  def is_gift_card?
    @rewardType == 'gift card'
  end

  def variable_price?
    @valueType == 'VARIABLE_VALUE'
  end

  def fixed_price?
    @valueType == 'FIXED_VALUE'
  end

  # Is this reward purchasable given a certain number of cents available to purchase it?
  # True if reward is available and user has enough cents
  # False if reward is unavailable OR user doesn't have enough cents
  #
  # Example:
  #   >> reward.purchasable?(500)
  #    => true # reward is available and costs <= 500 cents
  #
  # Arguments:
  #   balance_in_cents: (Integer)
  def purchasable?(balance_in_cents)
    return false unless available

    if variable_price?
      min_price <= balance_in_cents
    else
      denomination <= balance_in_cents
    end
  end

  # Converts price in cents for given field to Money object using currency_code
  #
  # Example:
  #   >> reward.to_money(:unit_price)
  #    => #<Money fractional:5000 currency:USD>
  #
  # Arguments:
  #   field_name: (Symbol - must be :min_price, :max_price, or :denomination)
  def to_money(field_name)
    return nil unless [:min_price, :max_price, :denomination].include?(field_name)

    Money.new(self.send(field_name), currency_code)
  end
end
