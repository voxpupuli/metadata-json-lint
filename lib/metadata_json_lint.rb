#!/usr/bin/env ruby

module MetadataJsonLint
  def MetadataJsonLint.parse(metadata)

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

    # Deprecated fields
    # From: https://docs.puppetlabs.com/puppet/latest/reference/modules_publishing.html#write-a-metadatajson-file

    deprecated_fields = ["types", "checksum"]

    deprecated_fields.each do |field|
      if not parsed[field].nil?
        puts "Error: Deprecated field '#{field}' found in metadata.json."
        error_state = true
      end
    end


    if error_state
      abort("Errors found in metadata.json")
    end

  end
end
