#!/bin/bash
set -u

# Ensure this can be called from outside its directory.
cd $(dirname $0)

SUCCESS=0
FAILURE=1
STATUS=0

fail() {
  echo $*
  STATUS=1
}

# Tests the metadata-json-lint bin and if no additional arguments are given, also the rake task.
test() {
  local name=$1; shift
  local expect=$1; shift

  test_bin $name $expect $*
  # Only check the Rakefile when no additional arguments were passed to metadata-json-lint.
  #   In these cases, rake will likely have the opposite return code and cause false failures.
  if [ $# -eq 0 ]; then
    test_rake $name $expect metadata_lint
  fi
}

test_bin() {
  local name=$1; shift
  local expect=$1; shift
  local RESULT=-1
  (cd $name;
    bundle exec metadata-json-lint $* metadata.json >/dev/null 2>&1
    RESULT=$?
    if [ $RESULT -ne $expect ]; then
      fail "Failing Test '${name}' (bin)"
    else
      echo "Successful Test '${name}' (bin)"
    fi
  )
}

test_rake() {
  local name=$1; shift
  local expect=$1; shift
  local rake_task="${1-metadata_lint}"
  local RESULT=-1;

  (cd $name;
    bundle exec rake $rake_task >/dev/null 2>&1
    RESULT=$?
    if [ $RESULT -ne $expect ]; then
      fail "Failing Test '${name}' (rake: ${rake_task})"
    else
      echo "Successful Test '${name}' (rake: ${rake_task})"
    fi;
  )
}

# Run a broken one, expect FAILURE
test "broken" $FAILURE

# Run a perfect one, expect SUCCESS
test "perfect" $SUCCESS

# Run a broken one, expect FAILURE
test "noname" $FAILURE

# Run a broken one, expect FAILURE
test "types" $FAILURE

# Run a broken one, expect FAILURE
test "multiple_problems" $FAILURE

# Run a broken one, expect FAILURE
test "duplicate-dep" $FAILURE
# Run with --no-fail-on-warnings, expect SUCCESS
test "duplicate-dep" $SUCCESS --no-fail-on-warnings

# Run a broken one, expect FAILURE
test "bad_license" $FAILURE
# Run with --no-strict-license, expect SUCCESS
test "bad_license" $SUCCESS --no-strict-license

# Run a broken one, expect FAILURE
test "long_summary" $FAILURE

# Run a broken one, expect FAILURE
test "mixed_version_syntax" $FAILURE

# Run one with empty dependencies array, expect SUCCESS
test "no_dependencies" $SUCCESS

# Run one with open ended dependency, expect SUCCESS
test "open_ended_dependency" $SUCCESS
# Run one with open ended dependency and --strict-dependencies, expect FAILURE
test "open_ended_dependency" $FAILURE --strict-dependencies

# Run one with missing version_requirement and --no-strict-dependency, expect SUCCESS
test "missing_version_requirement" $SUCCESS
# Run one with open ended dependency and --strict-dependencies, expect FAILURE
test "missing_version_requirement" $FAILURE --strict-dependencies

# Run test for "proprietary"-licensed modules, expect SUCCESS
test "proprietary" $SUCCESS

# Run without a metadata.json or Rakefile, expect FAILURE
test "no_files" $FAILURE

# Run with tags in an array in metadata.json, expect SUCCESS
test "tags_with_array" $SUCCESS

# Run with tags not in an array in metadata.json, expect FAILURE
test "tags_no_array" $FAILURE

# Test running without specifying file to parse
(
  cd perfect
  bundle exec metadata-json-lint
  if [ $? -ne 0 ]; then
    fail "Failing Test 'running without specifying metadata.json' (bin)"
  else
    echo "Successful Test 'running without specifying metadata.json' (bin)"
  fi
)

# Test changing the rake task using settings
test_bin "rake_global_options" $FAILURE
test_rake "rake_global_options" $SUCCESS

# Test multiple lints with different options
test_rake "rake_multiple_json_options" $SUCCESS metadata_lint_multi

exit $STATUS
