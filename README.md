# metadata-json-lint

The metadata-json-lint tool validates and lints `metadata.json` files in Puppet modules against style guidelines from the [Puppet Forge module metadata](https://docs.puppet.com/puppet/latest/modules_publishing.html#write-a-metadatajson-file) recommendations.

## Compatibility

metadata-json-lint is compatible with Ruby versions 2.0.0, 2.1.9, 2.3.1, and 2.4.1.

## Installation

via `gem` command:
``` shell
gem install metadata-json-lint
```

via Gemfile:
``` ruby
gem 'metadata-json-lint'
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
require 'metadata_json_lint'
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
* `--[no-]strict-puppet-version`: Whether to fail if Puppet version requirements are open-ended or no longer supported. Defaults to `false`.

## Contributors

A big thank you to the [contributors](https://github.com/voxpupuli/metadata-json-lint/graphs/contributors).

## Making a new release

How to make a new release?

* update the gemspec file with the desired version

```console
$ git diff
diff --git a/metadata-json-lint.gemspec b/metadata-json-lint.gemspec
index c86668e..6a3ad38 100644
--- a/metadata-json-lint.gemspec
+++ b/metadata-json-lint.gemspec
@@ -2,7 +2,7 @@ require 'date'

 Gem::Specification.new do |s|
   s.name        = 'metadata-json-lint'
-  s.version     = '2.4.0'
+  s.version     = '2.5.0'
   s.date        = Date.today.to_s
   s.summary     = 'metadata-json-lint /path/to/metadata.json'
   s.description = 'Utility to verify Puppet metadata.json files'
```

* export a GitHub access token as environment variable:

```console
export CHANGELOG_GITHUB_TOKEN=*token*
```

* Install deps and generate the changelog

```console
$ bundle install --path .vendor/ --jobs=$(nproc) --with release
$ bundle exec rake changelog
Found 25 tags
Fetching tags dates: 25/25
Sorting tags...
Received issues: 103
Pull Request count: 77
Filtered pull requests: 72
Filtered issues: 26
Fetching events for issues and PR: 98
Fetching closed dates for issues: 98/98
Fetching SHAs for tags: 25
Associating PRs with tags: 72/72
Generating entry...
Done!
Generated log placed in ~/metadata-json-lint/CHANGELOG.md
```

* Check the diff for `CHANGELOG.md`. Does it contain a breaking change but the
new version is only a minor bump? Does the new release only contains bug fixes?
Adjust the version properly while honouring semantic versioning. If required,
regenerate the `CHANGELOG.md`. Afterwards submit it as a PR.

* If it gets approved, merge the PR, create a git tag on that and push it.
