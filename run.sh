#!/bin/bash

project="$1"
startup_method="$2"
error_flag="$3"
tool4d_bin="$4"


if [[ -z "$project" ]]; then # TODO: instead create a new step with condition if:  github.event.inputs.project != ''
    echo "💡 Define a project to run or use `tool4d` binary" 
    exit 0
fi

if [[ "$project" == "*" ]]; then
    echo "🔎 Try to find 4DProject file in workspace"
    project=$(find . -name "*.4DProject" -not -path "./Components/*" | head -n 1)
    echo "$project"
fi
if [[ $RUNNER_OS == 'Windows' ]]; then
    project=$(echo "$project" | sed 's/^\.\///g')
    project=$(echo "$project" | sed 's/\//\\/g')
    project="${{ github.workspace }}\\$project"
    echo "$project"
fi

echo "🚀 Run code"

options="--dataless"

if [[ -z "$startup_method" ]]; then
    "$tool4d_bin" --project "$project" $options
else
    "$tool4d_bin" --project "$project" $options --skip-onstartup --startup-method "$startup_method" # TODO: do only one call (but parsing failed of arg...)
fi
exit_code=$?

if [[ -z "$error_flag" ]]; then
    error_flag="error"
fi
if [ $exit_code -eq 0 ]; then
    # chec error file flag 
    # TODO: allow user to change flag path or expect 4d could quit with a specific exit code)
    if [[ -f "$error_flag" ]]; then
    exit 1
    fi
else
    exit $exit_code
fi
