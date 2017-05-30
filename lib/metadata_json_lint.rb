require 'json'
require 'spdx-licenses'
require 'optparse'

require 'metadata-json-lint/version_requirement'

module MetadataJsonLint
  def options
    @options ||= Struct.new(
      :fail_on_warnings,
      :strict_license,
      :strict_dependencies,
      :format
    ).new(
      true, # fail_on_warnings
      true, # strict_license
      false, # strict_dependencies
      'text', # format
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

      opts.on('-f', '--format FORMAT', %i[text json], 'The format in which results will be output (text, json)') do |format|
        options[:format] = format
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
    @errors = []
    @warnings = []

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

    # Fields required to be in metadata.json
    # From: https://docs.puppetlabs.com/puppet/latest/reference/modules_publishing.html#write-a-metadatajson-file
    required_fields = %w[name version author license summary source dependencies]
    required_fields.each do |field|
      if parsed[field].nil?
        error :required_fields, "Required field '#{field}' not found in metadata.json."
      end
    end

    validate_dependencies!(parsed['dependencies']) if parsed['dependencies']

    # Deprecated fields
    # From: https://docs.puppetlabs.com/puppet/latest/reference/modules_publishing.html#write-a-metadatajson-file
    deprecated_fields = %w[types checksum]
    deprecated_fields.each do |field|
      unless parsed[field].nil?
        error :deprecated_fields, "Deprecated field '#{field}' found in metadata.json."
      end
    end

    # The nested 'requirements' name of 'pe' is deprecated as well.
    # https://groups.google.com/forum/?utm_medium=email&utm_source=footer#!msg/puppet-users/nkRPvG4q0Oo/GmXa109aJQAJ
    validate_requirements!(parsed['requirements']) if parsed['requirements']

    # Summary can not be over 144 characters:
    # From: https://forge.puppetlabs.com/razorsedge/snmp/3.3.1/scores
    if !parsed['summary'].nil? && parsed['summary'].size > 144
      error :summary, 'Field \'summary\' exceeds 144 characters in metadata.json.'
    end

    # Shoulds/recommendations
    # From: https://docs.puppetlabs.com/puppet/latest/reference/modules_publishing.html#write-a-metadatajson-file
    #
    if !parsed['license'].nil? && !SpdxLicenses.exist?(parsed['license']) && parsed['license'] != 'proprietary'
      msg = "License identifier #{parsed['license']} is not in the SPDX list: http://spdx.org/licenses/"

      options[:strict_license] == true ? error(:license, msg) : warn(:license, msg)
    end

    if !parsed['tags'].nil? && !parsed['tags'].is_a?(Array)
      error :tags, "Tags must be in an array. Currently it's a #{parsed['tags'].class}."
    end

    if !@errors.empty? || !@warnings.empty?
      result = @errors.empty? ? "Warnings found in #{metadata}" : "Errors found in #{metadata}"

      case options[:format]
      when :json
        puts JSON.fast_generate(:result => result, :warnings => @warnings, :errors => @errors)
      else
        @warnings.each { |warn| puts "(WARN) #{warn}" }
        @errors.each { |err| puts "(ERROR) #{err}" }
        puts result
      end

      if !@errors.empty? || (!@warnings.empty? && (options[:fail_on_warnings] == true))
        exit(1)
      end
    end

    exit(0)
  end
  module_function :parse

  def validate_requirements!(requirements)
    requirements.each do |requirement|
      if requirement['name'] == 'pe'
        warn :requirements, "The 'pe' requirement is no longer supported by the Forge."
      end
    end
  end
  module_function :validate_requirements!

  def validate_dependencies!(deps)
    dep_names = []
    deps.each do |dep|
      if dep_names.include?(dep['name'])
        warn :dependencies, "Duplicate dependencies on #{dep['name']}"
      end
      dep_names << dep['name']

      begin
        requirement = VersionRequirement.new(dep.fetch('version_requirement', ''))
      rescue ArgumentError => e
        # Raised when the version_requirement provided could not be parsed
        error :dependencies, "Invalid 'version_requirement' field in metadata.json: #{e}"
      end
      validate_version_requirement!(dep, requirement)

      # 'version_range' is no longer used by the forge
      # See https://tickets.puppetlabs.com/browse/PUP-2781
      if dep.key?('version_range')
        warn :dependencies, "Dependency #{dep['name']} has a 'version_range' attribute " \
          'which is no longer used by the forge.'
      end
    end
  end
  module_function :validate_dependencies!

  def validate_version_requirement!(dep, requirement)
    # Open ended dependency
    # From: https://docs.puppet.com/puppet/latest/reference/modules_metadata.html#best-practice-set-an-upper-bound-for-dependencies
    return unless requirement.open_ended?
    msg = "Dependency #{dep['name']} has an open " \
      "ended dependency version requirement #{dep['version_requirement']}"
    options[:strict_dependencies] == true ? error(:dependencies, msg) : warn(:dependencies, msg)
  end
  module_function :validate_version_requirement!

  def format_error(check, msg)
    case options[:format]
    when :json
      { :check => check, :msg => msg }
    else
      "#{check}: #{msg}"
    end
  end
  module_function :format_error

  def warn(check, msg)
    @warnings ||= []

    @warnings << format_error(check, msg)
  end
  module_function :warn

  def error(check, msg)
    @errors ||= []

    @errors << format_error(check, msg)
  end
  module_function :error
end
