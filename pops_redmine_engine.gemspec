$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "pops_redmine_engine/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "pops_redmine_engine"
  s.version     = PopsRedmineEngine::VERSION
  s.authors     = ["Alban Merino"]
  s.email       = ["amerino@dotgee.fr"]
  s.homepage    = "http://www.dotgee.fr"
  s.summary     = "Engine for redmine."
  s.description = "Engine for redmine.."

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 3.2.16"
  s.add_dependency "slim"
  s.add_dependency "timelineJS-rails", '~> 1.1.5'
  s.add_dependency "compass-rails"
  # s.add_dependency "awesome_nested_set"

end
