# Change Log

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).

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
