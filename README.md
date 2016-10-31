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

### Options

```
--[no-]strict-dependencies   Fail on open-ended module version dependencies
--[no-]strict-license        Don't fail on strict license check
--[no-]fail-on-warnings      Fail on any warnings
```

## Contributors

A Big thank you to the code contributors:

* Spencer Krum
* Rob Nelson
* Matthew Haughton
* Dominic Cleal
* Tim Meusel
* Igor Galić
* Richard Pijnenburg
* Djuri Baars
* Joseph (Jy) Yaworski
* Mike Arnold
* Nan Liu
* Raphaël Pinson
* Sebastien Badia
* William Van Hevelingen
