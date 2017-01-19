# metadata-json-linter

Simple tool to validate and lint `metadata.json` files in Puppet modules as
recommended in Puppet Forge style guidelines from [Puppet forge metadata style
quide](https://docs.puppetlabs.com/puppet/latest/reference/modules_publishing.html#write-a-metadatajson-file)

## Compatibility

metadata-json-lint is compatible with Ruby versions 2.0.0, 2.1.9 and
2.3.1.

## Installation

```shell
gem install metadata-json-lint
```

## Usage

### By hand

In your shell, with the `metadata-json-lint` and the path of your `metadata.json` file

```shell
metadata-json-lint /path/to/metadata.json
```

### Rake task

If you are already using the puppet_spec_helper, you get metadata-json-lint
checking for free using the 'validate' task.

You can also integrate `metadata.json` lint in you tests, using the rake tast.
You can add `require 'metadata-json-lint/rake_task'` to your Rakefile and then
run

```ruby
rake metadata_lint
```

You can also set options using a rake task when manually defining it:

```ruby
require 'metadata-json-lint'
task :metadata_lint do
  MetadataJsonLint.parse('metadata.json') do |options|
      options.strict_license = false
  end
end
```

Alternative:

```ruby
require 'metadata-json-lint/rake_task'
MetadataJsonLint.options.strict_license = false
```

### Options

```
--[no-]strict-dependencies   Fail on open-ended module version dependencies. Defaults to 'false'.
--[no-]strict-license        Don't fail on strict license check. Defaults to 'true'.
--[no-]fail-on-warnings      Fail on any warnings. Defaults to 'true'.

```

## Contributors

A Big thank you to the
[contributors](https://github.com/voxpupuli/metadata-json-lint/graphs/contributors)
