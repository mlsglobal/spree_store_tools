
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'spree_store_tools/version'

Gem::Specification.new do |spec|
  spec.name          = 'spree_store_tools'
  spec.version       = SpreeStoreTools::VERSION
  spec.authors       = ['willwoodlief']
  spec.email         = ['w.woodlief@mlsglobal.com']

  spec.summary       = 'Uses the spree api to make free stuff. If a store item is not free will add credit '
  spec.description   = 'Uses admin login and a user id to log in the user without a password'
  spec.homepage      = "https://github.com/mlsglobal/spree_store_tools"
  spec.license       = 'MIT'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
   # spec.metadata['allowed_push_host'] = "http://mygemserver.com"
  else
    raise 'RubyGems 2.0 or newer is required to protect against public gem push'
  end

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'thor'
  spec.add_dependency 'figaro'
  spec.add_dependency 'ap'
  spec.add_dependency 'awesome_print'
  spec.add_dependency 'curb'
  spec.add_dependency 'mechanize'

  # gem "awesome_print", require:"ap"


  spec.add_development_dependency 'bundler', '~> 1.16'
  spec.add_development_dependency 'minitest', '~> 5.0'
  spec.add_development_dependency 'rake', '~> 10.0'
end
