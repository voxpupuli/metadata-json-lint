require 'rake'
require 'rake/tasklib'

desc 'Run metadata-json-lint'
task :metadata_lint do
  if File.exist?('metadata.json')
    require 'metadata_json_lint'
    abort unless MetadataJsonLint.parse('metadata.json')
  end
end
