# metadata-json-lint

The metadata-json-lint tool validates and lints `metadata.json` files in Puppet modules against style guidelines from the [Puppet Forge module metadata](https://docs.puppet.com/puppet/latest/modules_publishing.html#write-a-metadatajson-file) recommendations.

## Compatibility

metadata-json-lint is compatible with Ruby versions 2.0.0, 2.1.9, 2.3.1, and 2.4.1.

## Installation

Puppet 4.9.0 and newer:

via `gem` command:
``` shell
gem install metadata-json-lint
```

via Gemfile:
``` ruby
gem 'metadata-json-lint'
```

**Puppet 4.8.x and older:**

via `gem` command:
``` shell
gem install metadata-json-lint semantic_puppet
```

via Gemfile:
``` ruby
gem 'metadata-json-lint'
gem 'semantic_puppet
```

## Usage

### Testing with metadata-json-lint

On the command line, run `metadata-json-lint` with the path of your `metadata.json` file:

```shell
metadata-json-lint /path/to/metadata.json
```

### Testing with metadata-json-lint as a Rake task

If you are already using `puppet_spec_helper`, the 'validate' task already includes `metadata-json-lint`.

You can also integrate `metadata-json-lint` checks into your tests using the Rake task. Add `require 'metadata-json-lint/rake_task'` to your `Rakefile`, and then run:

```ruby
rake metadata_lint
```

To set options for the Rake task, include them when you define the task:

```ruby
require 'metadata-json-lint'
task :metadata_lint do
  MetadataJsonLint.parse('metadata.json') do |options|
      options.strict_license = false
  end
end
```

Alternatively, set the option after requiring the Rake task:

```ruby
require 'metadata-json-lint/rake_task'
MetadataJsonLint.options.strict_license = false
```

### Options

* `--[no-]strict-dependencies`: Whether to fail if module version dependencies are open-ended. Defaults to `false`.
* `--[no-]strict-license`: Whether to fail on strict license check. Defaults to `true`.
* `--[no-]fail-on-warnings`: Whether to fail on warnings. Defaults to `true`.

## Contributors

A big thank you to the [contributors](https://github.com/voxpupuli/metadata-json-lint/graphs/contributors).
