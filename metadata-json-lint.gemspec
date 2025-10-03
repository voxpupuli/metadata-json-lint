Gem::Specification.new do |s|
  s.name        = 'metadata-json-lint'
  s.version     = '5.0.0'
  s.summary     = 'metadata-json-lint /path/to/metadata.json'
  s.description = 'Utility to verify Puppet metadata.json files'
  s.authors     = ['Vox Pupuli']
  s.email       = 'voxpupuli@groups.io'

  s.files       = `git ls-files -z`.split("\x0")
  s.executables = s.files.grep(%r{^bin/}) { |f| File.basename(f) }

  s.homepage    = 'https://github.com/voxpupuli/metadata-json-lint'
  s.license     = 'Apache-2.0'

  s.required_ruby_version = '>= 3.2.0'

  s.add_dependency 'json-schema', '>= 2.8', '< 7.0'
  s.add_dependency 'semantic_puppet', '~> 1.0'
  s.add_dependency 'spdx-licenses', '~> 1.0'
  s.add_development_dependency 'rake', '~> 13.0', '>= 13.0.6'
  s.add_development_dependency 'rspec', '~> 3.12'
  s.add_development_dependency 'voxpupuli-rubocop', '~> 5.0.0'
end
