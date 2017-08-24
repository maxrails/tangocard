class TangoCard::Reward < TangoCard::Base
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
    attrs_list = %w{ rewardName currencyCode status valueType rewardType faceValue minValue maxValue createdDate
                    lastUpdateDate countries }
    initialize_read_variables attrs_list, [], params
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
