#!/bin/bash

export SUCCESS=0
export FAILURE=1

# Run a broken one, expect FAILURE
../bin/metadata-json-lint metadata-broken.json >/dev/null 2>&1
RESULT=$?
if [ $RESULT -ne $FAILURE ]; then
    echo "Failing Test #1"
fi

# Run a perfect one, expect SUCCESS
../bin/metadata-json-lint metadata-perfect.json
RESULT=$?
if [ $RESULT -ne $SUCCESS ]; then
    echo "Failing Test #2"
fi

# Run a broken one, expect FAILURE
../bin/metadata-json-lint metadata-noname.json >/dev/null 2>&1
RESULT=$?
if [ $RESULT -ne $FAILURE ]; then
    echo "Failing Test #3"
fi

# Run a broken one, expect FAILURE
../bin/metadata-json-lint metadata-types.json >/dev/null 2>&1
RESULT=$?
if [ $RESULT -ne $FAILURE ]; then
    echo "Failing Test #4"
fi


# Run a broken one, expect FAILURE
../bin/metadata-json-lint metadata-multiple_problems.json >/dev/null 2>&1
RESULT=$?
if [ $RESULT -ne $FAILURE ]; then
    echo "Failing Test #5"
fi

# Run a broken one, expect FAILURE
../bin/metadata-json-lint metadata-duplicate-dep.json >/dev/null 2>&1
RESULT=$?
if [ $RESULT -ne $FAILURE ]; then
    echo "Failing Test #6"
fi
