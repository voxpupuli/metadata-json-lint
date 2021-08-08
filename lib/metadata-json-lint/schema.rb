require 'json-schema'

module MetadataJsonLint
  # Provides validation of metadata.json against a JSON schema document
  # maintained in this class. Provides a good first pass over the metadata with
  # type checking and basic format/length validations.
  #
  # rubocop:disable Metrics/ClassLength # schema data structure is quite large
  class Schema
    # Based on https://docs.puppet.com/puppet/latest/modules_metadata.html
    #
    def schema
      {
        '$schema' => 'http://json-schema.org/draft-04/schema#',
        'properties' => {
          'author' => {
            'type' => 'string',
          },
          'data_provider' => {
            'type' => %w[null string],
          },
          'dependencies' => {
            'type' => 'array',
            'items' => {
              'properties' => {
                'name' => {
                  'type' => 'string',
                  'pattern' => '^\w+[/-][a-z][a-z0-9_]*$',
                },
                'version_requirement' => {
                  'type' => 'string',
                },
              },
              'required' => %w[
                name
              ],
            },
          },
          'description' => {
            'type' => 'string',
          },
          'issues_url' => {
            'type' => 'string',
            'format' => 'uri',
          },
          'license' => {
            'type' => 'string',
          },
          'operatingsystem_support' => {
            'type' => 'array',
            'items' => {
              'properties' => {
                'operatingsystem' => {
                  'type' => 'string',
                },
                'operatingsystemrelease' => {
                  'type' => 'array',
                  'items' => {
                    'type' => 'string',
                  },
                },
              },
              'required' => %w[
                operatingsystem
              ],
            },
          },
          'name' => {
            'type' => 'string',
            'pattern' => '^\w+-[a-z][a-z0-9_]*$',
          },
          'project_page' => {
            'type' => 'string',
            'format' => 'uri',
          },
          # Undocumented but in use: https://tickets.puppetlabs.com/browse/DOCUMENT-387
          'requirements' => {
            'type' => 'array',
            'items' => {
              'properties' => {
                'name' => {
                  'type' => 'string',
                },
                'version_requirement' => {
                  'type' => 'string',
                },
              },
              'required' => %w[
                name
              ],
            },
          },
          'source' => {
            'type' => 'string',
          },
          'summary' => {
            'type' => 'string',
            'maxLength' => 144,
          },
          'tags' => {
            'type' => 'array',
            'items' => {
              'type' => 'string',
            },
          },
          'version' => {
            'type' => 'string',
            'format' => 'semver',
          },
        },
        # from https://docs.puppetlabs.com/puppet/latest/reference/modules_publishing.html#write-a-metadatajson-file
        'required' => %w[
          author
          dependencies
          license
          name
          source
          summary
          version
        ],
      }
    end

    def validate(data, options = {})
      JSON::Validator.register_format_validator('semver', method(:semver_validator))

      JSON::Validator.fully_validate(schema, data, options.merge(errors_as_objects: true)).map do |error|
        field = error[:fragment].split('/')[1]
        field = 'root' if field.nil? || field.empty?

        message = error[:message]
                  .sub(/ in schema [\w-]+/, '') # remove schema UUID, not needed in output
                  .sub(%r{'#/}, "'") # remove root #/ prefix from document paths
                  .sub("property ''", 'file') # call the root #/ node the file

        { field: field, message: message }
      end
    end

    private

    def semver_full_regex
      @semver_full_regex ||= begin
        # Version string matching regexes
        numeric = '(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)' # Major . Minor . Patch
        pre     = '(?:-([0-9A-Za-z-]+(?:\.[0-9A-Za-z-]+)*))?' # Prerelease
        build   = '(?:\+([0-9A-Za-z-]+(?:\.[0-9A-Za-z-]+)*))?' # Build
        full    = numeric + pre + build

        /\A#{full}\Z/
      end
    end

    def semver_validator(value)
      if defined?(SemanticPuppet::Version)
        begin
          SemanticPuppet::Version.parse(value)
        rescue SemanticPuppet::Version::ValidationFailure => e
          raise JSON::Schema::CustomFormatError, "must be a valid semantic version: #{e.message}"
        end
      elsif value.match(semver_full_regex).nil?
        raise JSON::Schema::CustomFormatError, "must be a valid semantic version: Unable to parse '#{value}' as a semantic version identifier"
      end
    end
  end
end
# rubocop:enable Metrics/ClassLength
