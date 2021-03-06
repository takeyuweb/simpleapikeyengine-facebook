$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "simpleapikeyengine-facebook/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "simpleapikeyengine-facebook"
  s.version     = SimpleApiKeyEngineFacebook::VERSION
  s.authors     = ['Yuichi Takeuchi']
  s.email       = ['uzuki05@takeyu-web.com']
  s.homepage    = 'https://github.com/takeyuweb/simpleapikeyengine'
  s.summary     = 'Facebook Provider for simple_api_key_engine gem.'
  s.description = '(Description for simpleapikeyengine-facebook)'
  s.license     = 'MIT'

  s.files = Dir["{lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  s.add_dependency "rails", "~> 4"
  s.add_dependency 'koala'
  s.add_dependency 'oauth2'
  s.add_dependency 'simpleapikeyengine', '~> 0.1.0'

  s.add_development_dependency "sqlite3"
  s.add_development_dependency 'rspec'
end
