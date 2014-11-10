$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "simpleapikeyengine-facebook/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "simpleapikeyengine-facebook"
  s.version     = SimpleApiKeyEngineFacebook::VERSION
  s.authors     = ["TODO: Your name"]
  s.email       = ["TODO: Your email"]
  s.homepage    = "TODO"
  s.summary     = "TODO: Summary of SimpleApiKeyEngineFacebook."
  s.description = "TODO: Description of SimpleApiKeyEngineFacebook."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]

  s.add_dependency "rails", "~> 4.1.6"
  s.add_dependency 'koala'
  s.add_dependency 'oauth2'
  s.add_dependency 'simpleapikeyengine', '~> 0.0.1'

  s.add_development_dependency "sqlite3"
end
