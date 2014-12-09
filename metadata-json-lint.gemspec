Gem::Specification.new do |s|
  s.name        = 'metadata-json-lint'
  s.version     = '0.0.2'
  s.date        = '2014-10-06'
  s.summary     = "metadata-json-lint /path/to/metadata.json"
  s.description = "Utility to verify Puppet metadata.json files"
  s.authors     = ["Spencer Krum", "HP Development Corporation LP"]
  s.email       = 'krum.spencer@gmail.com'
  s.files       = ["bin/metadata-json-lint", "lib/metadata_json_lint.rb"]
  s.executables << 'metadata-json-lint'
  s.homepage    =
    'http://github.com/nibalizer/metadata-json-lint'
  s.license       = 'Apache 2'
end
