#!/bin/bash

product_line="$1"
version="$2"
build="$3"

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
CONFIG_FILE="$SCRIPT_DIR/config.yml"

if [ -z "$product_line" ] || [ -z "$version" ] || [ -z "$build" ]; then
    echo "test"

    curl -sfL https://raw.githubusercontent.com/e-marchand/tool4d-action/main/config.yml -o "dlconfig.yml"
   
    if [ -f "dlconfig.yml" ]; then
        yq v  "dlconfig.yml"
        if [[ "$?" -eq "0" ]]; then
            CONFIG_FILE="dlconfig.yml"
        fi
    fi
fi

if [[ -z "$product_line" ]]; then
    product_line=$(cat $CONFIG_FILE | yq ".product-line")
fi
if [[ -z "$version" ]]; then
    version=$(cat $CONFIG_FILE | yq ".version")
fi
if [[ -z "$build" ]]; then
    build=$(cat $CONFIG_FILE | yq ".build")
fi

if [[ "$build" == "official" ]]; then
    build=$(cat $CONFIG_FILE | yq ".official")
fi

# fill RUNNER OS to test locally
if [[ -z "$RUNNER_OS" ]]; then
    if [[ "$OSTYPE" == "darwin"* ]]; then
        RUNNER_OS="macOS"
    elif [ "$OSTYPE" == "cygwin" ] || [ "$OSTYPE" == "msys" ] || [ "$OSTYPE" == "win32" ] ; then
        RUNNER_OS="Windows"
    fi
fi

if [[ $RUNNER_OS == 'macOS' ]]; then
    # check arch? if github provide arm
    url="https://resources-download.4d.com/release/$product_line/$version/$build/mac/tool4d_v20.0_mac_x86.tar.xz"
    option=xzf # xJf ?
    tool4d_bin=./tool4d.app/Contents/MacOS/tool4d
elif [[ $RUNNER_OS == 'Windows' ]]; then
    url="https://resources-download.4d.com/release/$product_line/$version/$build/win/tool4d_v20.0_win.tar.xz"
    option=xJf
    tool4d_bin=./tool4d/tool4d.exe
else
    >&2 echo "❌ Not supported runner OS: $RUNNER_OS"
    exit 1
fi

echo "⬇️  Download tool4d fom $url" 
curl "$url" -o tool4d.tar.xz -sL
status=$?
if [[ "$status" -eq 0 ]]; then
    echo "📦 Unpack"
    tar $option tool4d.tar.xz
else
    >&2 echo "❌ Failed to download with status $status"
    exit 2
fi

if  [[ -f "$tool4d_bin" ]]; then
    echo "🎉 Downloaded successfully into $tool4d_bin"
    if [[ ! -z "$GITHUB_OUTPUT" ]]; then
        echo "tool4d=$tool4d_bin" >> $GITHUB_OUTPUT
    fi
else
    >&2 echo "❌ Failed to unpack tool4d"
    exit 3
fi

