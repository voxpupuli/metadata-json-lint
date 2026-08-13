==================
metadata-json-lint
==================

-------------------------------------------------------
Validate and lint metadata.json files in Puppet modules
-------------------------------------------------------

:Author: Gabriel Filion
:Date: 2020
:Manual section: 1

Synopsis
========

| metadata-json-lint [options] <path>

Description
===========

The ``metadata-json-lint`` tool validates and lints ``metadata.json`` files in
Puppet modules against style guidelines from the Puppet Forge module metadata
recommendations.

The tool can be used as a binary command, or it can be used as a rake task.
See the project's ``README.md`` file for instructions on how to use the rake
task.

Options
=======

| **[no-]strict-dependencies**
|     Whether to fail if module version dependencies are open-ended. Defaults
|     to ``false``.

| **[no-]strict-license**
|     Whether to fail on strict license check. Defaults to `true`.

| **[no-]fail-on-warnings**
|     Whether to fail on warnings. Defaults to `true`.

| **[no-]strict-puppet-version**
|     Whether to fail if Puppet version requirements are open-ended or no
|     longer supported. Defaults to `false`.

Examples
========

Test a metadata.json file::

        $ metadata-json-lint /path/to/metadata.json

See also
========

https://docs.puppet.com/puppet/latest/modules_publishing.html#write-a-metadatajson-file
