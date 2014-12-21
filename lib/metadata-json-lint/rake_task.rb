require 'rake'
require 'rake/tasklib'
require 'metadata_json_lint'
require 'json'

desc 'Run metadata-json-lint'
task :metadata_lint do
  if File.exist?('metadata.json')
    MetadataJsonLint.parse('metadata.json')
  end
end
