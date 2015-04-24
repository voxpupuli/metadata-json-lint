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
  (
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

# Run a broken one, expect FAILURE
test "bad_license" $FAILURE

# Run a broken one, expect FAILURE
test "long_summary" $FAILURE

# Run a broken one, expect SUCCESS
(
  cd duplicate-dep
  ../../bin/metadata-json-lint --no-fail-on-warnings metadata.json >/dev/null 2>&1
  RESULT=$?
  if [ $RESULT -ne $SUCCESS ]; then
      fail "Failing Test 'duplicate-dep' with --no-fail-on-warnings"
  fi
)

# Run a broken one, expect SUCCESS
(
  cd bad_license
  ../../bin/metadata-json-lint --no-strict-license metadata.json >/dev/null 2>&1
  RESULT=$?
  if [ $RESULT -ne $SUCCESS ]; then
      fail "Failing Test 'bad_license' with --no-strict-license"
  fi
)

# Run a broken one, expect SUCCESS
# Testing on no file given
../bin/metadata-json-lint >/dev/null 2>&1
RESULT=$?
if [ $RESULT -ne $FAILURE ]; then
    fail "Failing Test with no file"
fi

exit $STATUS
