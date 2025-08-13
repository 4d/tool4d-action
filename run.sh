#!/bin/bash

project="$1"
startup_method="$2"
error_flag="$3"
tool4d_bin="$4"
user_param="$5"
workspace="$6"

if [[ -z "$project" ]]; then # TODO: instead create a new step with condition if:  github.event.inputs.project != ''
    echo "💡 Define a project to run or use tool4d binary" 
    exit 0
fi

if [[ "$project" == "*" ]]; then
    echo "🔎 Try to find 4DProject file in workspace"
    project=$(find . -name "*.4DProject" -not -path "./Components/*" | head -n 1)
    echo "$project"
fi

if  [[ ! -f "$project" ]]; then
    >&2 echo "❌ project $project seems to not exist and could not be run"
    exit 1
fi

# Output the final project path for GitHub Actions
if [[ ! -z "$GITHUB_OUTPUT" ]]; then
    echo "project=$project" >> "$GITHUB_OUTPUT"
fi

if [[ -z "$error_flag" ]]; then
    error_flag="error"
fi

if [[ -f "$error_flag" ]]; then
    rm "$error_flag"
fi

if [[ $RUNNER_OS == 'Windows' ]]; then
    project=$(echo "$project" | sed 's/\//\\/g')
    echo "🪟  $project"
fi

echo "🚀 Run code"

options="--dataless"
if [[ ! -z "$user_param" ]]; then
    echo "➡️ $user_param"
fi

if [[ -z "$startup_method" ]]; then
    "$tool4d_bin" --project "$project" $options --user-param "$user_param"
else
    "$tool4d_bin" --project "$project" $options --user-param "$user_param" --skip-onstartup --startup-method "$startup_method" # TODO: do only one call (but parsing failed of arg...)
fi
exit_code=$?

echo "...end running code ($exit_code)"

if [ $exit_code -eq 0 ]; then
    # check error flag file
    # CLEAN: expect 4d could quit with a specific exit code instead
    if [[ -f "$error_flag" ]]; then
        if [[ "$RUNNER_DEBUG" -eq 1 ]]; then
           echo "error flag found"
           cat $"error_flag"
        fi
        exit 1
    fi
else
    exit $exit_code
fi
