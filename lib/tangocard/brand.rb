class Tangocard::Brand
  # brandKey
  # brandName
  # disclaimer
  # description
  # shortDescription
  # terms
  # createdDate
  # lastUpdateDate
  # imageUrls
  # status
  # items  - rewards

  # "imageUrls": ["80w-326ppi", "130w-326ppi", "200w-326ppi", "278w-326ppi", "300w-326ppi", "1200w-326ppi"]

  attr_reader :brandKey,
              :brandName,
              :disclaimer,
              :description,
              :shortDescription,
              :terms,
              :createdDate,
              :lastUpdateDate,
              :images,
              :status,
              :rewards

  private_class_method :new

  def self.all verbose: true, use_cache: false
    rewards_index = Tangocard::Raas.rewards_index use_cache: use_cache, verbose: verbose
    resp          = rewards_index.parsed_response
    unless resp['brands'].present? && resp['brands'].length > 0
      raise Tangocard::RaasException.new("Tangocard error with response code #{rewards_index.code}")
    end
    #puts resp['brands']
    resp['brands'].collect{ |p| new(p) }
  end

  def self.all_active use_cache = false
    all.select{ |t| t.status == 'active' }
  end

  def self.find brandKey: nil, brandName: nil, price: nil
    raise "To find brand need 'brandKey' or 'brandName'" if brandKey.blank? && brandName.blank?
    condition = if brandKey.present?
                  { name: 'brandKey', value: brandKey }
                elsif brandName.present?
                  { name: 'brandName', value: brandName }
                end

    res       = all_active.select{ |b| b[ condition[:name] ] == condition[:value] }.first
    if price.present?
      rewards = res.rewards
      if rewards.length > 0
        rewards.select{ |t| t.is_gift_card? && t.fixed_price? && t.faceValue == price && t.status == 'active' }.first
      else
        nil
      end
    else
      res
    end
  end

  def initialize(params)
    %w{ brandKey brandName lastUpdateDate shortDescription status }.each do |param|
      eval "@#{param} = params['#{param}']"
    end

    if params['imageUrls'].present?
      @images   = Tangocard::BrandImage.new( params['imageUrls'] )
    end

    if params['items'].present?
      @rewards  = params['items'].map{ |p| Tangocard::Reward.new(p) }
    end
  end

  def method_missing name, *args, &block
    if name == :[] && args.length == 1 && block.nil? && self.methods.include?(args[0].to_sym)
      self.send(args[0].to_sym)
    else
      super
    end
  end
end
