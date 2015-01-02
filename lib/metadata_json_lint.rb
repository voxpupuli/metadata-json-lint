require 'json'
require 'spdx-licenses'
require 'optparse'
require 'metadata-json-lint/semantic/version'
require 'metadata-json-lint/semantic/version_range'

module MetadataJsonLint
  def run
    options = {
      :fail_on_warnings  => true,
      :strict_license    => true,
      :strict_dependency => false
    }

    OptionParser.new do |opts|
      opts.banner = "Usage: metadata-json-lint [options] metadata.json"

      opts.on("--[no-]strict-license", "Don't fail on strict license check") do |v|
        options[:strict_license] = v
      end

      opts.on("--[no-]strict-dependency", "Strict dependency version checking") do |v|
        options[:strict_dependency] = v
      end

      opts.on("--[no-]fail-on-warnings", "Fail on any warnings") do |v|
        options[:fail_on_warnings] = v
      end
    end.parse!

    @options = options

    if ARGV[0].nil?
      abort("Error: Must provide a metadata.json file to parse")
    end

    MetadataJsonLint.parse(ARGV.first)
  end
  module_function :run

  def parse(metadata)
    f = File.read(metadata)

    begin
      parsed = JSON.parse(f)
    rescue Exception => e
      abort("Error: Unable to parse metadata.json: #{e.exception}")
    end

    # Fields required to be in metadata.json
    # From: https://docs.puppetlabs.com/puppet/latest/reference/modules_publishing.html#write-a-metadatajson-file
    error_state = false

    required_fields = [ "name", "version", "author", "license", "summary", "source", "dependencies" ]

    required_fields.each do |field|
      if parsed[field].nil?
        puts "Error: Required field '#{field}' not found in metadata.json."
        error_state = true
      end
    end

    deps = parsed['dependencies']
    dep_names = []
    deps.each do |dep|
      if dep_names.include?(dep['name'])
        puts "Error: duplicate dependencies on #{dep['name']}"
        error_state = true
      end
      dep_names << dep['name']
    end

    # Check for open endend versions in dependencies.
    # https://docs.puppetlabs.com/puppet/latest/reference/modules_publishing.html#dependencies-in-metadatajson
    deps.each do |dep|
      if Semantic::VersionRange.parse(dep['version_requirement']).open_end?
        puts "Warning: Dependency #{dep['name']} has an open ended dependency version requirement #{dep['version_requirement']}"
        error_state = true if @options[:strict_dependency]
      end
    end

    # Deprecated fields
    # From: https://docs.puppetlabs.com/puppet/latest/reference/modules_publishing.html#write-a-metadatajson-file

    deprecated_fields = ["types", "checksum"]

    deprecated_fields.each do |field|
      if not parsed[field].nil?
        puts "Error: Deprecated field '#{field}' found in metadata.json."
        error_state = true
      end
    end

    # Shoulds/recommendations
    # From: https://docs.puppetlabs.com/puppet/latest/reference/modules_publishing.html#write-a-metadatajson-file

    if !parsed['license'].nil? && !SpdxLicenses.exist?(parsed['license'])
      puts "Warning: License identifier #{parsed['license']} is not in the SPDX list: http://spdx.org/licenses/"
      error_state = true if @options[:strict_license]
    end

    if error_state
      if @options[:fail_on_warnings] == true
        abort("Errors found in #{metadata}")
      else
        puts "Errors found in #{metadata}"
      end
    end

  end
  module_function :parse
end
