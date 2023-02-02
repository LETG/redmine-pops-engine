require_relative "lib/pops_redmine_engine/version"

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

  s.add_dependency "rails"
  s.add_dependency "slim"
  s.add_dependency "sass", "~>3.4.0"
  s.add_dependency "timelineJS-rails"
  s.add_dependency "compass-rails"
  s.add_dependency 'savon'
  s.add_dependency "cocoon"
end
