require 'httparty'
require 'money'
require 'ostruct'
require 'active_support'
require 'active_support/cache/memory_store'
require 'tango_card/version'
require 'json'
require 'bundler/setup'


module TangoCard

  CACHE_PREFIX = "tango_card:#{VERSION}:"

  class Configuration
    attr_accessor :name, :key, :base_uri, :default_brands, :local_images, :sku_blacklist,
                  :use_cache, :cache, :logger, :default_image_size

    def initialize
      self.name               = nil
      self.key                = nil
      self.default_image_size = nil

      # For testing purposes only !!!
      self.name               = 'OneClassTest'
      self.key                = 'VPgEfkbdzfROUQFTEidgQiUmvu!Icp$HjbpOQETUkFzZEz'
      self.default_image_size = 200
      #

      self.base_uri           = 'https://integration-api.tangocard.com'
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
    configuration.cache.write("#{TangoCard::CACHE_PREFIX}rewards_index", TangoCard::Raas.rewards_index(use_cache: false))
    configuration.logger.info('Warmed Tangocard cache')
  end

  # for testing purposes
  def self.reload!
    files = $LOADED_FEATURES.select { |feat| feat =~ /\/tango_card\// }
    files.each { |file| load file }
    'Gem reloaded successfully'
  end

end

require 'tango_card/base'

require 'tango_card/response'
require 'tango_card/raas'
require 'tango_card/account'
require 'tango_card/brand'
require 'tango_card/brand_image'
require 'tango_card/customer'
require 'tango_card/order'
require 'tango_card/reward'
require 'tango_card/exchange_rate'

def self.reload!
  TangoCard.reload!
end