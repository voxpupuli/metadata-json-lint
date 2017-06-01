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
  cd $name;
  bundle exec metadata-json-lint $* metadata.json >last_output 2>&1
  RESULT=$?
  if [ $RESULT -ne $expect ]; then
    fail "Failing Test '${name}' (unexpected exit code '${RESULT}' instead of '${expect}') (bin)"
    echo "    Note: you can examine '${name}/last_output' for any output"
  else
    # If the test is not expected to succeed then it should match an expected output
    if [ $expect -eq $SUCCESS ]; then
      echo "Successful Test '${name}' (bin)"
    else
      if [ -f expected ]; then
        if grep --quiet -f expected last_output; then
          echo "Successful Test '${name}' (bin)"
        else
          fail "Failing Test '${name}' (did not get expected output) (bin)"
          echo "    Comparing '${name}/expected' with '${name}/last_output':"
          echo "        Expected: '`cat expected`'"
          echo "        Actual: '`cat last_output`'"
        fi
      else
        fail "Failing Test '${name}' (expected output file ${name}/expected is missing) (bin)"
        echo "    Actual output that needs tested ('${name}/last_output'): '`cat last_output`'"
      fi
    fi
  fi
  cd ..
}

test_rake() {
  local name=$1; shift
  local expect=$1; shift
  local rake_task="${1-metadata_lint}"
  local RESULT=-1;

  cd $name;
  bundle exec rake $rake_task >last_rake_output 2>&1
  RESULT=$?
  if [ $RESULT -ne $expect ]; then
    fail "Failing Test '${name}' (rake: ${rake_task})"
  else
    echo "Successful Test '${name}' (rake: ${rake_task})"
  fi;
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
test "bad_license" $SUCCESS --no-strict-license --no-fail-on-warnings

# Run a broken one, expect FAILURE
test "long_summary" $FAILURE

# Run a broken one, expect FAILURE
test "mixed_version_syntax" $FAILURE

# Run one with empty dependencies array, expect SUCCESS
test "no_dependencies" $SUCCESS

# Run one with open ended dependency, expect SUCCESS
test "open_ended_dependency" $SUCCESS --no-fail-on-warnings
# Run one with open ended dependency and --strict-dependencies, expect FAILURE
test "open_ended_dependency" $FAILURE --strict-dependencies

# Run one with missing version_requirement and --no-strict-dependency, expect SUCCESS
test "missing_version_requirement" $SUCCESS --no-fail-on-warnings
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

# Run with json output format
test "json_format" $FAILURE --format json

# Test running without specifying file to parse
cd perfect
bundle exec metadata-json-lint
if [ $? -ne 0 ]; then
    fail "Failing Test 'running without specifying metadata.json' (bin)"
else
    echo "Successful Test 'running without specifying metadata.json' (bin)"
fi
cd ..

# Test changing the rake task using settings
# The bin test will fail due to strict licensing
# The rake test should pass due to licensing option being set in Rakefile
test_bin "rake_global_options" $FAILURE
test_rake "rake_global_options" $SUCCESS

# Test multiple lints with different options
test_rake "rake_multiple_json_options" $SUCCESS metadata_lint_multi

# Test successful lint followed by further tasks
test_rake "rake_chaining" $SUCCESS test
if ! grep -qx "Successfully linted" rake_chaining/last_rake_output; then
  fail "Failing Test 'rake_chaining' failed to run second rake task"
fi

exit $STATUS
