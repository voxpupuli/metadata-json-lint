module MetadataJsonLint
  # Parses a string module version requirement with semantic_puppet and
  # provides methods to analyse it for lint warnings
  class VersionRequirement
    def initialize(requirement)
      @requirement = requirement

      if defined?(SemanticPuppet::VersionRange)
        @range = SemanticPuppet::VersionRange.parse(requirement)
        raise ArgumentError, "Range matches no versions: \"#{requirement}\"" if @range == SemanticPuppet::VersionRange::EMPTY_RANGE
      elsif requirement.match(/\A[a-z0-9*.\-^~><=|\t ]*\Z/i).nil?
        raise ArgumentError, "Unparsable version range: \"#{requirement}\""
      end
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
      if range
        range.end == SemanticPuppet::Version::MAX
      else
        # Empty requirement strings are open-ended.
        return true if requirement.strip.empty?

        # Strip superfluous whitespace.
        range_set = requirement.gsub(/([><=~^])(?:\s+|\s*v)/, '\1')

        # Split on logical OR
        ranges = range_set.split(/\s*\|\|\s*/)

        # Returns true if any range includes a '>' but not a corresponding '<'
        # which should be the only way to declare an open-ended range.
        ranges.select { |r| r.include?('>') }.any? { |r| !r.include?('<') }
      end
    end

    def puppet_eol?
      true if range.begin < SemanticPuppet::Version.parse(MIN_PUPPET_VER)
    end

    def ver_range
      range
    end

    def min
      range.begin
    end

    def max
      range.end
    end

    private

    attr_reader :range, :requirement
  end
end
