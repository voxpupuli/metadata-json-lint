require 'json'
require 'spdx-licenses'
require 'optparse'
require 'semantic_puppet'

module MetadataJsonLint
  def options
    @options ||= Struct.new(
      :fail_on_warnings,
      :strict_license,
      :strict_dependencies
    ).new(
      true, # fail_on_warnings
      true, # strict_license
      false # strict_dependencies
    )
  end
  module_function :options

  def run
    OptionParser.new do |opts|
      opts.banner = 'Usage: metadata-json-lint [options] [metadata.json]'

      opts.on('--[no-]strict-dependencies', "Fail on open-ended module version dependencies. Defaults to '#{options[:strict_dependencies]}'.") do |v|
        options[:strict_dependencies] = v
      end

      opts.on('--[no-]strict-license', "Don't fail on strict license check. Defaults to '#{options[:strict_license]}'.") do |v|
        options[:strict_license] = v
      end

      opts.on('--[no-]fail-on-warnings', "Fail on any warnings. Defaults to '#{options[:fail_on_warnings]}'.") do |v|
        options[:fail_on_warnings] = v
      end
    end.parse!

    mj = if ARGV[0].nil?
           if File.readable?('metadata.json')
             'metadata.json'
           else
             abort('Error: metadata.json is not readable or does not exist.')
           end
         else
           ARGV[0]
         end

    MetadataJsonLint.parse(mj)
  end
  module_function :run

  def parse(metadata)
    # Small hack to use the module settings as defaults but allow overriding for different rake tasks
    options = options().clone
    # Configuration from rake tasks
    yield options if block_given?
    begin
      f = File.read(metadata)
    rescue Exception => e
      abort("Error: Unable to read metadata file: #{e.exception}")
    end

    begin
      parsed = JSON.parse(f)
    rescue Exception => e
      abort("Error: Unable to parse metadata.json: #{e.exception}")
    end

    error_state = false

    # Fields required to be in metadata.json
    # From: https://docs.puppetlabs.com/puppet/latest/reference/modules_publishing.html#write-a-metadatajson-file
    required_fields = %w(name version author license summary source dependencies)
    required_fields.each do |field|
      if parsed[field].nil?
        puts "Error: Required field '#{field}' not found in metadata.json."
        error_state = true
      end
    end

    error_state ||= invalid_dependencies?(parsed['dependencies']) if parsed['dependencies']

    # Deprecated fields
    # From: https://docs.puppetlabs.com/puppet/latest/reference/modules_publishing.html#write-a-metadatajson-file
    deprecated_fields = %w(types checksum)
    deprecated_fields.each do |field|
      unless parsed[field].nil?
        puts "Error: Deprecated field '#{field}' found in metadata.json."
        error_state = true
      end
    end

    # The nested 'requirements' name of 'pe' is deprecated as well.
    # https://groups.google.com/forum/?utm_medium=email&utm_source=footer#!msg/puppet-users/nkRPvG4q0Oo/GmXa109aJQAJ
    error_state ||= invalid_requirements?(parsed['requirements']) if parsed['requirements']

    # Summary can not be over 144 characters:
    # From: https://forge.puppetlabs.com/razorsedge/snmp/3.3.1/scores
    if !parsed['summary'].nil? && parsed['summary'].size > 144
      puts 'Error: summary exceeds 144 characters in metadata.json.'
      error_state = true
    end

    # Shoulds/recommendations
    # From: https://docs.puppetlabs.com/puppet/latest/reference/modules_publishing.html#write-a-metadatajson-file
    #
    if !parsed['license'].nil? && !SpdxLicenses.exist?(parsed['license']) && parsed['license'] != 'proprietary'
      puts "Warning: License identifier #{parsed['license']} is not in the SPDX list: http://spdx.org/licenses/"
      error_state = true if options[:strict_license]
    end

    if !parsed['tags'].nil? && !parsed['tags'].is_a?(Array)
      puts "Warning: Tags must be in an array. Currently it's a #{parsed['tags'].class}."
      error_state = true
    end

    return unless error_state
    if options[:fail_on_warnings] == true
      abort("Errors found in #{metadata}")
    else
      puts "Errors found in #{metadata}"
    end
  end
  module_function :parse

  def invalid_requirements?(requirements)
    error_state = false
    requirements.each do |requirement|
      if requirement['name'] == 'pe'
        puts "The 'pe' requirement is no longer supported by the Forge."
        error_state = true
      end
    end
    error_state
  end
  module_function :invalid_requirements?

  def invalid_dependencies?(deps)
    error_state = false
    dep_names = []
    deps.each do |dep|
      if dep_names.include?(dep['name'])
        puts "Error: duplicate dependencies on #{dep['name']}"
        error_state = true
      end
      dep_names << dep['name']

      # Open ended dependency
      # From: https://docs.puppet.com/puppet/latest/reference/modules_metadata.html#best-practice-set-an-upper-bound-for-dependencies
      begin
        next unless dep['version_requirement'].nil? || open_ended?(dep['version_requirement'])
        puts "Warning: Dependency #{dep['name']} has an open " \
          "ended dependency version requirement #{dep['version_requirement']}"
        error_state = true if options[:strict_dependencies]
      rescue ArgumentError => e
        # Raised when the version_requirement provided could not be parsed
        puts "Invalid 'version_requirement' field in metadata.json: #{e}"
        error_state = true
      end

      # 'version_range' is no longer used by the forge
      # See https://tickets.puppetlabs.com/browse/PUP-2781
      next unless dep['version_range']
      puts "Warning: Dependency #{dep['name']} has a 'version_range' attribute " \
        'which is no longer used by the forge.'
      error_state = true
    end
    error_state
  end
  module_function :invalid_dependencies?

  def open_ended?(module_end)
    SemanticPuppet::VersionRange.parse(module_end).end == SemanticPuppet::Version::MAX
  end
  module_function :open_ended?
end
