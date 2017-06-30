require 'date'

Gem::Specification.new do |s|
  s.name        = 'metadata-json-lint'
  s.version     = '2.0.1'
  s.date        = Date.today.to_s
  s.summary     = 'metadata-json-lint /path/to/metadata.json'
  s.description = 'Utility to verify Puppet metadata.json files'
  s.authors     = ['Vox Pupuli']
  s.email       = 'voxpupuli@groups.io'

  s.files       = `git ls-files -z`.split("\x0")
  s.executables = s.files.grep(%r{^bin/}) { |f| File.basename(f) }
  s.test_files  = s.files.grep(%r{^(tests|spec)/})

  s.homepage    = 'http://github.com/voxpupuli/metadata-json-lint'
  s.license     = 'Apache-2.0'

  s.required_ruby_version = '>= 2.0.0'
  s.add_runtime_dependency 'spdx-licenses', '~> 1.0'
  s.add_runtime_dependency 'json-schema', '~> 2.8'
  s.add_runtime_dependency 'puppet', '>= 4.7.0', '< 6.0.0'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'rubocop'
end
