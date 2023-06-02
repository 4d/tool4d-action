#!/bin/bash

if [[ -z "$RUNNER_OS" ]]; then
    if [[ "$OSTYPE" == "darwin"* ]]; then
        RUNNER_OS="macOS"
    elif [ "$OSTYPE" == "cygwin" ] || [ "$OSTYPE" == "msys" ] || [ "$OSTYPE" == "win32" ] ; then
        RUNNER_OS="Windows"
    fi
fi

if [[ $RUNNER_OS == 'macOS' ]]; then
    tool4d_bin=./tool4d.app/Contents/MacOS/tool4d
elif [[ $RUNNER_OS == 'Windows' ]]; then
    tool4d_bin=./tool4d/tool4d.exe
else
    >&2 echo "❌ Not supported runner OS: $RUNNER_OS"
    exit 1
fi

if  [[ ! -f "$tool4d_bin" ]]; then
    ./download.sh 
fi
if  [[ ! -f "$tool4d_bin" ]]; then
    >&2 echo "❌ No tool 4d to run"
    exit 3
fi
finalstatus=0
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

project_relative="Project\\tool4d-action-test.4DProject"
startup_method="main"
error_flag="error"
tool4d_bin=$(realpath $tool4d_bin)
user_param=""

# test with a test project in same parent directory
if [[ $RUNNER_OS == 'Windows' ]]; then
    workspace=$(cmd //c cd)"\\..\\tool4d-action-test\\"
    project_relative="Project\\tool4d-action-test.4DProject"
else
    workspace=$(realpath "../tool4d-action-test")"/"
    project_relative="Project/tool4d-action-test.4DProject"
fi

cd "$workspace"

project="$workspace$project_relative"
echo "🏃 Run $project"
$SCRIPT_DIR/run.sh "$project" "$startup_method" "$error_flag" "$tool4d_bin" "$user_param" "$workspace"
status=$?
if [[ "$status" -eq 0 ]]; then
    echo "✅ Run ok"
else
    >&2 echo "❌ Failed to run"
    finalstatus=1
fi

echo ""
project=$project_relative
echo "🏃 Run $project"
$SCRIPT_DIR/run.sh "$project" "$startup_method" "$error_flag" "$tool4d_bin" "$user_param" "$workspace"
status=$?
if [[ "$status" -eq 0 ]]; then
    echo "✅ Run ok"
else
    >&2 echo "❌ Failed to run"
    finalstatus=1
fi

echo ""
project=$(echo "$project_relative" | sed 's/\\/\//g')
echo "🏃 Run $project"
$SCRIPT_DIR/run.sh "$project" "$startup_method" "$error_flag" "$tool4d_bin" "$user_param" "$workspace"
status=$?
if [[ "$status" -eq 0 ]]; then
    echo "✅ Run ok"
else
    >&2 echo "❌ Failed to run"
    finalstatus=1
fi

if [[ $RUNNER_OS == 'Windows' ]]; then
    echo ""
    project=".\\"$project_relative
    echo "🏃 Run $project"
    $SCRIPT_DIR/run.sh "$project" "$startup_method" "$error_flag" "$tool4d_bin" "$user_param" "$workspace"
    status=$?
    if [[ "$status" -eq 0 ]]; then
        echo "✅ Run ok"
    else
        >&2 echo "❌ Failed to run"
        finalstatus=1
    fi
fi

exit $finalstatus
