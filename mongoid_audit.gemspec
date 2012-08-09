# -*- encoding: utf-8 -*-
require File.expand_path('../lib/mongoid_audit/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Paul Smith"]
  gem.email         = ["pauls@basecampops.com"]
  gem.description   = "Allows you to add auditing to most any mongoid collection"
  gem.summary       = %q{TODO: Write a gem summary}
  gem.homepage      = "https://github.com/BaseCampOps/mongoid_audit"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "mongoid_audit"
  gem.require_paths = ["lib"]
  gem.version       = MongoidAudit::
  
  gem.add_runtime_dependency "mongoid", "~> 3.0.3"
  
end
