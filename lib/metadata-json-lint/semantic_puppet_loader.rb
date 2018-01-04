module MetadataJsonLint
  # Attempts the various methods of loading SemanticPuppet.
  module SemanticPuppetLoader
    def try_load
      try_load_puppet
      return if defined?(SemanticPuppet)

      try_load_semantic
      return if defined?(SemanticPuppet)

      try_load_semantic_puppet
      return if defined?(SemanticPuppet)

      warn 'Could not find semantic_puppet gem, falling back to internal functionality. Version checks may be less robust.'
    end
    module_function :try_load

    # Most modern Puppet versions have SemanticPuppet vendored in the proper
    # namespace and automatically load it at require time.
    def try_load_puppet
      require 'puppet'
    rescue LoadError
      nil
    end
    module_function :try_load_puppet

    # Older Puppet 4.x versions have SemanticPuppet vendored but under the
    # Semantic namespace and require it on demand, so we need to load it
    # ourselves and then alias it to SemanticPuppet for convenience.
    def try_load_semantic
      require 'semantic'
      Kernel.const_set('SemanticPuppet', Semantic)
    rescue LoadError
      nil
    end
    module_function :try_load_semantic

    # If Puppet is not available or is a version that does not have
    # SemanticPuppet vendored, try to load the external gem.
    def try_load_semantic_puppet
      require 'semantic_puppet'
    rescue LoadError
      nil
    end
    module_function :try_load_semantic_puppet
  end
end
