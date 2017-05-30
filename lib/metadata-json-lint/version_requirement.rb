require 'semantic_puppet'

module MetadataJsonLint
  # Parses a string module version requirement with semantic_puppet and
  # provides methods to analyse it for lint warnings
  class VersionRequirement
    def initialize(requirement)
      @requirement = requirement
      @range = SemanticPuppet::VersionRange.parse(requirement)
    end

    def open_ended?
      @range.end == SemanticPuppet::Version::MAX
    end

    private

    attr_reader :range, :requirement
  end
end
