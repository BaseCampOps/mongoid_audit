# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)
require 'mongoid_audit/version'

Gem::Specification.new do |gem|
  gem.authors       = ["Paul Smith"]
  gem.email         = ["pauls@basecampops.com"]
  gem.description   = "Allows you to add auditing to most any mongoid collection"
  gem.summary       = "Allows you to add auditing to most any mongoid collection"
  gem.homepage      = "https://github.com/BaseCampOps/mongoid_audit"

  gem.files         = Dir['lib/**/*.rb']
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "mongoid_audit"
  gem.require_paths = ["lib"]
  gem.version       = MongoidAudit::VERSION
  
  gem.add_dependency "mongoid", "~> 3.0.0"
  gem.add_dependency "activesupport", "~> 3.2.6"
  
end
