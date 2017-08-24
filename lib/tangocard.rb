require 'httparty'
require 'money'
require 'ostruct'
require 'active_support'
require 'active_support/cache/memory_store'
require 'tangocard/version'
require 'json'

module Tangocard

  CACHE_PREFIX = "tangocard:#{VERSION}:"

  class Configuration
    attr_accessor :name, :key, :base_uri, :default_brands, :local_images, :sku_blacklist,
                  :use_cache, :cache, :logger, :default_image_size

    def initialize
      self.name = nil
      self.key = nil
      self.default_image_size = nil

      # For testing purposes only !!!
      self.name = 'OneClassTest'
      self.key = 'VPgEfkbdzfROUQFTEidgQiUmvu!Icp$HjbpOQETUkFzZEz'
      self.default_image_size = 200
      #

      self.base_uri = 'https://integration-api.tangocard.com'
      self.default_brands = []
      self.local_images = {}
      self.sku_blacklist = []
      self.use_cache = true
      self.cache = ActiveSupport::Cache::MemoryStore.new
      self.logger = Logger.new(STDOUT)
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
    configuration.cache.write("#{Tangocard::CACHE_PREFIX}rewards_index", Tangocard::Raas.rewards_index(use_cache: false))
    configuration.logger.info('Warmed Tangocard cache')
  end

  # for testing purposes
  def self.reload!
    files = $LOADED_FEATURES.select { |feat| feat =~ /\/tangocard\// }
    files.each { |file| load file }
    'Gem reloaded successfully'
  end

end

require 'tangocard/response'
require 'tangocard/raas'
require 'tangocard/account'
require 'tangocard/account_create_failed_exception'
require 'tangocard/account_customer_not_found_exception'
require 'tangocard/account_delete_credit_card_failed_exception'
require 'tangocard/account_register_credit_card_failed_exception'
require 'tangocard/account_fund_failed_exception'
require 'tangocard/brand'
require 'tangocard/brand_image'
require 'tangocard/customer'
require 'tangocard/order'
require 'tangocard/order_create_failed_exception'
require 'tangocard/order_not_found_exception'
require 'tangocard/raas_exception'
require 'tangocard/reward'
require 'tangocard/exchange_rate'

def self.reload!
  Tangocard.reload!
end