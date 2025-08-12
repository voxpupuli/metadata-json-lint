require 'json'
require 'spdx-licenses'
require 'optparse'
require 'semantic_puppet'

require 'metadata-json-lint/schema'
require 'metadata-json-lint/version_requirement'

module MetadataJsonLint
  MIN_PUPPET_VER = '4.10.0'.freeze
  # Regex looks for:
  # 1. Invalid escape sequences (\x or incomplete \u)
  INVALID_ESCAPE_REGEX = %r{\\[^"/bfnrtu]|\\u(?![0-9a-fA-F]{4})}

  def options
    @options ||= Struct.new(
      :fail_on_warnings,
      :strict_license,
      :strict_dependencies,
      :strict_puppet_version,
      :format,
    ).new(
      true, # fail_on_warnings
      true, # strict_license
      false, # strict_dependencies
      false, # strict_puppet_version
      'text', # format
    )
  end
  module_function :options

  def run
    OptionParser.new do |opts|
      opts.banner = 'Usage: metadata-json-lint [options] [metadata.json]'

      opts.on('--[no-]strict-dependencies',
              "Fail on open-ended module version dependencies. Defaults to '#{options[:strict_dependencies]}'.") do |v|
        options[:strict_dependencies] = v
      end

      opts.on('--[no-]strict-license',
              "Don't fail on strict license check. Defaults to '#{options[:strict_license]}'.") do |v|
        options[:strict_license] = v
      end

      opts.on('--[no-]fail-on-warnings', "Fail on any warnings. Defaults to '#{options[:fail_on_warnings]}'.") do |v|
        options[:fail_on_warnings] = v
      end

      opts.on('--[no-]strict-puppet-version',
              "Fail on strict Puppet Version check based on current supported Puppet versions. Defaults to '#{options[:strict_puppet_version]}'.") do |v|
        options[:strict_puppet_version] = v
      end

      opts.on('-f', '--format FORMAT', %i[text json],
              'The format in which results will be output (text, json)') do |format|
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

    exit(MetadataJsonLint.parse(mj) ? 0 : 1)
  end
  module_function :run

  def contains_invalid_escape?(content)
    content.match?(INVALID_ESCAPE_REGEX)
  end
  module_function :contains_invalid_escape?

  def misses_newline_at_end?(content)
    content[-1] != "\n"
  end
  module_function :misses_newline_at_end?

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

    abort('Error: metadata.json does not have a valid newline at the end') if misses_newline_at_end?(f)

    abort('Error: Unable to parse metadata.json: Invalid escape character in string') if contains_invalid_escape?(f)

    begin
      parsed = JSON.parse(f)
    rescue Exception => e
      abort("Error: Unable to parse metadata.json: #{e.exception}")
    end

    # Validate basic structure against JSON schema
    schema_errors = Schema.new.validate(parsed)
    schema_errors.each do |err|
      error ((err[:field] == 'root') ? :required_fields : err[:field]), err[:message]
    end

    validate_dependencies!(parsed['dependencies']) if parsed['dependencies']

    # Deprecated fields
    # From: https://docs.puppetlabs.com/puppet/latest/reference/modules_publishing.html#write-a-metadatajson-file
    deprecated_fields = %w[types checksum]
    deprecated_fields.each do |field|
      error :deprecated_fields, "Deprecated field '#{field}' found in metadata.json." unless parsed[field].nil?
    end

    # The nested 'requirements' name of 'pe' is deprecated as well.
    # https://groups.google.com/forum/?utm_medium=email&utm_source=footer#!msg/puppet-users/nkRPvG4q0Oo/GmXa109aJQAJ
    validate_requirements!(parsed['requirements']) if parsed['requirements']

    # Shoulds/recommendations
    # From: https://docs.puppetlabs.com/puppet/latest/reference/modules_publishing.html#write-a-metadatajson-file
    #
    if options[:strict_license] && !parsed['license'].nil? && !SpdxLicenses.exist?(parsed['license']) && parsed['license'] != 'proprietary'
      msg = "License identifier #{parsed['license']} is not in the SPDX list: http://spdx.org/licenses/"
      warn(:license, msg)
    end

    if !@errors.empty? || !@warnings.empty?
      result = @errors.empty? ? "Warnings found in #{metadata}" : "Errors found in #{metadata}"

      case options[:format]
      when :json
        puts JSON.fast_generate(result: result, warnings: @warnings, errors: @errors)
      else
        @warnings.each { |warn| puts "(WARN) #{warn}" }
        @errors.each { |err| puts "(ERROR) #{err}" }
        puts result
      end

      return false if !@errors.empty? || (!@warnings.empty? && (options[:fail_on_warnings] == true))
    end

    true
  end
  module_function :parse

  def validate_requirements_unique(requirements)
    names = requirements.map { |x| x['name'] }
    counts = Hash.new(0)

    names.each { |name| counts[name.downcase] += 1 }

    counts.each do |k, v|
      error :requirements, "Duplicate entries in the 'requirements' list with the name '#{k}'" if v > 1
    end
  end
  module_function :validate_requirements_unique

  def validate_requirements!(requirements)
    return unless requirements.is_a?(Array)

    requirements.each do |requirement|
      warn :requirements, "The 'pe' requirement is no longer supported by the Forge." if requirement['name'] == 'pe'

      begin
        puppet_req = VersionRequirement.new(requirement.fetch('version_requirement', ''))
      rescue ArgumentError => e
        # Raised when the version_requirement provided could not be parsed
        error :requirements, "Invalid 'version_requirement' field in metadata.json: #{e}"
      end

      validate_puppet_ver!(puppet_req) unless puppet_req.instance_variable_get(:@requirement).nil?
    end

    validate_requirements_unique(requirements)
  end
  module_function :validate_requirements!

  def validate_puppet_ver!(requirement)
    if options[:strict_puppet_version] && requirement.open_ended?
      warn(:requirement, "Puppet has an open ended version requirement #{requirement.ver_range}")
    end

    if options[:strict_puppet_version] && requirement.puppet_eol?
      warn(:requirement, "#{requirement.min} is no longer supported. Minimum supported version is #{MIN_PUPPET_VER}")
    end

    return unless requirement.mixed_syntax?

    warn(:requirement, 'Mixing "x" or "*" version syntax with operators is not recommended in ' \
                       "metadata.json, use one style in the puppet version: #{requirement.instance_variable_get(:@requirement)}")
  end
  module_function :validate_puppet_ver!

  def validate_dependencies!(deps)
    dep_names = []
    deps.each do |dep|
      warn :dependencies, "Duplicate dependencies on #{dep['name']}" if dep_names.include?(dep['name'])
      dep_names << dep['name']

      begin
        requirement = VersionRequirement.new(dep.fetch('version_requirement', ''))
      rescue ArgumentError => e
        # Raised when the version_requirement provided could not be parsed
        error :dependencies, "Invalid 'version_requirement' field in metadata.json: #{e}"
        # Skip to the next dependency
        next
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
    if options[:strict_dependencies] && requirement.open_ended?
      msg = "Dependency #{dep['name']} has an open " \
            "ended dependency version requirement #{dep['version_requirement']}"
      warn(:dependencies, msg)
    end

    # Mixing operator and wildcard version syntax
    # From: https://docs.puppet.com/puppet/latest/modules_metadata.html#version-specifiers
    # Supported in Puppet 5 and higher, but the syntax is unclear and incompatible with older versions
    return unless requirement.mixed_syntax?

    warn(:dependencies, 'Mixing "x" or "*" version syntax with operators is not recommended in ' \
                        "metadata.json, use one style in the #{dep['name']} dependency: #{dep['version_requirement']}")
  end
  module_function :validate_version_requirement!

  def format_error(check, msg)
    case options[:format]
    when :json
      { check: check, msg: msg }
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
