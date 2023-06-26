#!/bin/bash

product_line="$1"
version="$2"
build="$3"

if [[ -z "$product_line" ]]; then
    product_line="20.x" # CLEAN: get somewhere online latest?
fi
if [[ -z "$version" ]]; then
    version="20.0" # CLEAN: could warn if not correct according to product line
fi
if [[ -z "$build" ]]; then
    build="latest"
fi
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

    "$tool4d_bin" --version
else
    >&2 echo "❌ Failed to unpack tool4d"
    exit 3
fi

