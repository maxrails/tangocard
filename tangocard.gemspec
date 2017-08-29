$:.push File.expand_path('../lib', __FILE__)

# Maintain your gem's version:
require 'tango_card_v2/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'tango_card_v2'
  s.version     = TangoCardV2::VERSION
  s.authors     = [ 'Max K', 'Denis E' ]
  s.email       = ['max@oneclass.com']
  s.homepage    = 'https://oneclass.com'
  s.summary     = 'Ruby Wrapper for Tango Card RaaS API V2.'
  s.description = 'Tango Card Reward Delivery Platform (RDP). Checkout RAAS API v2 links: https://integration-www.tangocard.com/raas_api_console/v2/'

  s.files = Dir['{app,config,db,lib}/**/*'] + ['MIT-LICENSE', 'Rakefile', 'README.md']
  s.licenses = ['MIT']

  s.add_dependency 'httparty', '> 0.11'
  s.add_dependency 'money', '> 6.1'
  s.add_dependency 'i18n', '> 0.7'
  s.add_dependency 'activesupport', '> 4.2'
  s.add_development_dependency 'rspec', '> 3.5'
end
