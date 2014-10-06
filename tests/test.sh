#!/bin/bash

export SUCCESS=0
export FAILURE=1

# Run a broken one, expect FAILURE
../metadata-json-lint.rb metadata-broken.json >/dev/null 2>&1
RESULT=$?
if [ $RESULT -ne $FAILURE ]; then
    echo "Failing Test #1"
fi

# Run a perfect one, expect SUCCESS
../metadata-json-lint.rb metadata-perfect.json
RESULT=$?
if [ $RESULT -ne $SUCCESS ]; then
    echo "Failing Test #2"
fi

