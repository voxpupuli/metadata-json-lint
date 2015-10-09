require 'rake'
require 'rake/tasklib'
require 'metadata_json_lint'
require 'json'

desc 'Run metadata-json-lint'
task :metadata_lint do
  MetadataJsonLint.parse('metadata.json') if File.exist?('metadata.json')
end
