#!/bin/bash

SUCCESS=0
FAILURE=1
STATUS=0

fail() {
  echo $*
  STATUS=1
}

test() {
  name=$1; shift
  expect=$1; shift
  cd $name
  bundle exec metadata-json-lint $* metadata.json >/dev/null 2>&1
  RESULT=$?
  if [ $RESULT -ne $expect ]; then
      fail "Failing Test '${name}' (bin)"
  fi

  # Only check the Rakefile when no additional arguments were passed to metadata-json-lint.
  #   In these cases, rake will likely have the opposite return code and cause false failures.
  if [ $# -eq 0 ]; then
    bundle exec rake metadata_lint >/dev/null 2>&1
    RESULT=$?
    if [ $RESULT -ne $expect ]; then
        fail "Failing Test '${name}' (rake)"
    fi
  fi
  cd ..
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

exit $STATUS
