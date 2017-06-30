require 'puppet'

module MetadataJsonLint
  # Parses a string module version requirement with semantic_puppet and
  # provides methods to analyse it for lint warnings
  class VersionRequirement
    def initialize(requirement)
      @requirement = requirement
      @range = SemanticPuppet::VersionRange.parse(requirement)
    end

    # Whether the range uses a comparison operator (e.g. >=) with a wildcard
    # syntax, such as ">= 1.x" or "< 2.0.x"
    def mixed_syntax?
      !/
        [><=^~]{1,2} # comparison operators
        \s*
        \d\. # MAJOR
        (?:
          (?:x|\*) # MINOR is wildcard
          |
          \d\.(?:x|\*)  # MINOR is digit and PATCH is wildcard
        )
      /x.match(requirement).nil?
    end

    def open_ended?
      @range.end == SemanticPuppet::Version::MAX
    end

    private

    attr_reader :range, :requirement
  end
end
