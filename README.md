# metadata-json-linter

Simple tool to validate and lint `metadata.json` files in Puppet modules as
recommended in Puppet Forge style guidelines from [Puppet forge metadata style
quide](https://docs.puppetlabs.com/puppet/latest/reference/modules_publishing.html#write-a-metadatajson-file)

## Installation

```shell
gem install metadata-json-lint
```

## Usage

### By hand

In your shell, with the `metadata-json-lint` and the path of your `metadata.json` file

```shell
metadata-json-lint /path/too/metadata.json
```

### Rake task

You can also integrate `metadata.json` lint in you tests, using the rake tast.
You can add `require 'metadata-json-lint/rake_task'` to your Rakefile and then
run

```ruby
rake metadata_lint
```

### Options

```
--[no-]strict-license        Don't fail on strict license check
--[no-]fail-on-warnings      Fail on any warnings
```

## Contributors

A Big thank you to the code contributors:

* Richard Pijnenburg
* Dominic Cleal
* Igor Galić
* Mike Arnold

