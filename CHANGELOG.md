# Change Log

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).

## 2.3.0

* Add duplicate testing in requirements list
* Fix wrong license file content so GitHub can properly detect it
* Fix a typo in the README.md

## 2.2.0

* Validate Puppet version_requirement [#99](https://github.com/voxpupuli/metadata-json-lint/issues/99)
* Add optional check `--strict-puppet-version` to validate the Puppet Agent Version is not EOL or open ended [#100](https://github.com/voxpupuli/metadata-json-lint/pull/100)

## 2.1.0

### Changes

* Improve rendering of post\_install message by trimming unnecessary leading
  spaces [#89](https://github.com/voxpupuli/metadata-json-lint/pull/89)
* Fail when checking version requirements if the version range is empty
  [#91](https://github.com/voxpupuli/metadata-json-lint/pull/91)
* Pin `public_suffix` gem to < 3 for Ruby <= 2.0
  [#93](https://github.com/voxpupuli/metadata-json-lint/pull/93)

### Fixed

* Prevent metadata-json-lint from crashing when the `requirements` field does
  not contain an array
  [#94](https://github.com/voxpupuli/metadata-json-lint/pull/94)
* Fix loading of `semantic_puppet` so that it supports using version vendored
  in Puppet (if available)
  [#96](https://github.com/voxpupuli/metadata-json-lint/pull/96)

## 2.0.2

### Changes

* Make SemanticPuppet completely optional and remove dependency on Puppet [#86](https://github.com/voxpupuli/metadata-json-lint/pull/86)
* Only log open dependency warning with --strict-dependencies [#78](https://github.com/voxpupuli/metadata-json-lint/pull/78)

### Fixed

* Fix readme for gemfile usage [#84](https://github.com/voxpupuli/metadata-json-lint/pull/84)

## 2.0.1

### Changes

* Puppet 4.9.0 and newer uses the vendored `semantic_puppet` packaged with Puppet.
* If using Puppet 4.8.x and earlier, adding `semantic_puppet` to your Gemfile is required
as the vendored `semantic_puppet` was not packaged with Puppet prior to `4.9.0`
* Add test environment for Ruby 2.4.1 

## 2.0.0

### Changes

* The `semantic_puppet` gem is no longer included as a runtime dependency due to conflicts with Puppet 5.x libraries that break the `puppet module` command. As such, `semantic_puppet` must be added to a user's Gemfile in Puppet <= 4.x. See [Installation](https://github.com/voxpupuli/metadata-json-lint#installation) docs for more info
* `metadata-json-lint` now officially only supports Ruby >= 2.0.0

### Fixed

* Fix puppet 5.x `semantic_puppet` conflicts ([#79](https://github.com/voxpupuli/metadata-json-lint/issues/79))
* Clarify Ruby >= 2.x only support ([#74](https://github.com/voxpupuli/metadata-json-lint/issues/74))

## 1.2.2

### Fixed

* Fix `metadata_lint` rake task exiting on success, not continuing ([#70](https://github.com/voxpupuli/metadata-json-lint/issues/70))
* Fix failure on incorrect license warning when `--no-strict-license` used ([#69](https://github.com/voxpupuli/metadata-json-lint/issues/69))

## 1.2.1

### Fixed

* Fix missing lib/ files in published gem

## 1.2.0

### Added

* Add `--format`/`-f` option to support a JSON output format
* Add warning for mixed version range syntax, supported only in Puppet 5

### Changed

* The default text format mode now outputs more structured messages
* README has been edited and clarity improved

### Fixed

* Fix non-zero exit code caused by some checks

## 1.1.0

### Added

* Ensure module `tags` are correctly specified as an array ([#44](https://github.com/voxpupuli/metadata-json-lint/issues/44))
* Ensure `requirements` doesn't list the deprecated `pe` key ([#46](https://github.com/voxpupuli/metadata-json-lint/issues/46))
* Ensure `dependencies` aren't listed with `version_range` keys ([#47](https://github.com/voxpupuli/metadata-json-lint/issues/47))
* Support strictness configuration via Ruby API, for use in rake tasks definitions
* Show default strictness option values in `--help` output

### Fixed

* Fix unclear error message when metadata.json does not exist
* Fix gem publishing date
* Various test improvements, ensuring failures are caught accurately and precisely
