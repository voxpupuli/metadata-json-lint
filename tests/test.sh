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
  ../../bin/metadata-json-lint $* metadata.json >/dev/null 2>&1
  RESULT=$?
  if [ $RESULT -ne $expect ]; then
      fail "Failing Test '${name}' (bin)"
  fi
  rake metadata_lint >/dev/null 2>&1
  RESULT=$?
  if [ $RESULT -ne $expect ]; then
      fail "Failing Test '${name}' (rake)"
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

# Run a broken one, expect FAILURE
test "bad_license" $FAILURE

# Run a broken one, expect FAILURE
test "long_summary" $FAILURE

# Run a broken one, expect FAILURE
test "mixed_version_syntax" $FAILURE

# Run one with empty dependencies array, expect SUCCESS
test "no_dependencies" $SUCCESS

# Run one with open ended dependency and --no-strict-dependency, expect SUCCESS
test "open_ended_dependency" $SUCCESS

# Run one with missing version_requirement and --no-strict-dependency, expect SUCCESS
test "missing_version_requirement" $SUCCESS

# Run test for "proprietary"-licensed modules, expect SUCCESS
test "proprietary" $SUCCESS

# Run a broken one, expect SUCCESS
cd duplicate-dep
../../bin/metadata-json-lint --no-fail-on-warnings metadata.json >/dev/null 2>&1
RESULT=$?
if [ $RESULT -ne $SUCCESS ]; then
    fail "Failing Test 'duplicate-dep' with --no-fail-on-warnings"
fi
cd ..

# Run a broken one, expect SUCCESS
cd bad_license
../../bin/metadata-json-lint --no-strict-license metadata.json >/dev/null 2>&1
RESULT=$?
if [ $RESULT -ne $SUCCESS ]; then
    fail "Failing Test 'bad_license' with --no-strict-license"
fi
cd ..

# Run one with open ended dependency and --strict-dependency, expect FAILURE
cd open_ended_dependency
../../bin/metadata-json-lint --strict-dependencies metadata.json >/dev/null 2>&1
RESULT=$?
if [ $RESULT -ne $FAILURE ]; then
    echo "Failing Test with open ended dependency"
fi
cd ..

# Run one with missing version_requirement and --strict-dependency, expect FAILURE
cd missing_version_requirement
../../bin/metadata-json-lint --strict-dependencies metadata.json >/dev/null 2>&1
RESULT=$?
if [ $RESULT -ne $FAILURE ]; then
    echo "Failing Test with missing version_requirement"
fi
cd ..

# Run a broken one, expect FAILURE
# Testing on no file given
../bin/metadata-json-lint >/dev/null 2>&1
RESULT=$?
if [ $RESULT -ne $FAILURE ]; then
    fail "Failing Test with no file"
fi

exit $STATUS
