# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'enum_kit/constants'

Gem::Specification.new do |spec|
  spec.name          = 'enum_kit'
  spec.version       = EnumKit::VERSION
  spec.authors       = ['Nialto Services']
  spec.email         = ['support@nialtoservices.co.uk']

  spec.summary       = 'Native PostgreSQL enum support for Ruby on Rails.'
  spec.homepage      = 'https://github.com/nialtoservices/enum_kit'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.metadata['yard.run'] = 'yri'

  spec.add_runtime_dependency 'activerecord',  '>= 5.2.0', '< 6.1.0'
  spec.add_runtime_dependency 'activesupport', '>= 5.2.0', '< 6.1.0'
  spec.add_runtime_dependency 'pg'

  spec.add_development_dependency 'bundler',     '~> 2.0'
  spec.add_development_dependency 'combustion',  '~> 1.1'
  spec.add_development_dependency 'guard-rspec', '~> 4.7'
  spec.add_development_dependency 'rake',        '~> 13.0'
  spec.add_development_dependency 'rspec',       '~> 3.8'
  spec.add_development_dependency 'rspec-rails', '~> 3.8'
  spec.add_development_dependency 'rubocop',     '~> 0.77.0'
  spec.add_development_dependency 'yard',        '~> 0.9.20'
end
