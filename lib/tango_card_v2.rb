require 'httparty'
require 'money'
require 'ostruct'
require 'active_support'
require 'active_support/cache/memory_store'
require 'tango_card_v2/version'
require 'json'
require 'bundler/setup'


module TangoCardV2

  CACHE_PREFIX = "tango_card:#{VERSION}:"

  class Configuration
    attr_accessor :name, :key, :base_uri, :default_brands, :local_images, :sku_blacklist,
                  :use_cache, :cache, :logger, :default_image_size

    def initialize
      self.name               = nil
      self.key                = nil
      self.default_image_size = nil

      # For testing purposes only !!!
      #self.name               = 'OneClassTest'
      #self.key                = 'VPgEfkbdzfROUQFTEidgQiUmvu!Icp$HjbpOQETUkFzZEz'
      #self.default_image_size = 200
      #

      # self.base_uri           = 'https://api.tangocard.com'
      self.base_uri           = ''
      self.default_brands     = []
      self.local_images       = {}
      self.sku_blacklist      = []
      self.use_cache          = true
      self.cache              = ActiveSupport::Cache::MemoryStore.new
      self.logger             = Logger.new(STDOUT)
    end
  end

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.configure
    yield(configuration) if block_given?
    warm_cache if configuration.use_cache
  end

  def self.warm_cache
    configuration.cache.write("#{TangoCardV2::CACHE_PREFIX}rewards_index", TangoCardV2::Raas.rewards_index(use_cache: false))
    configuration.logger.info('Warmed Tangocard cache')
  end

  # for testing purposes
  def self.reload!
    files = $LOADED_FEATURES.select { |feat| feat =~ /\/tango_card\// }
    files.each { |file| load file }
    'Gem reloaded successfully'
  end

end

require 'tango_card_v2/base'

require 'tango_card_v2/response'
require 'tango_card_v2/raas'
require 'tango_card_v2/account'
require 'tango_card_v2/brand'
require 'tango_card_v2/brand_image'
require 'tango_card_v2/customer'
require 'tango_card_v2/order'
require 'tango_card_v2/reward'
require 'tango_card_v2/exchange_rate'

# def self.reload!
  # TangoCardV2.reload!
# end
