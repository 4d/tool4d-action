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

echo "⬇️ Download tool4d"
if [[ $RUNNER_OS == 'macOS' ]]; then
    # check arch? if github provide arm
    curl "https://resources-download.4d.com/release/$product_line/$version/$build/mac/tool4d_v20.0_mac_x86.tar.xz" -o tool4d.tar.xz -sL
    tar xzf tool4d.tar.xz
    tool4d_bin=./tool4d.app/Contents/MacOS/tool4d
elif [[ $RUNNER_OS == 'Windows' ]]; then
    curl "https://resources-download.4d.com/release/$product_line/$version/$build/win/tool4d_v20.0_win.tar.xz" -o tool4d.tar.xz -sL
    tar xJf tool4d.tar.xz
    tool4d_bin=./tool4d/tool4d.exe
else
    >&2 echo "Not supported runner OS $RUNNER_OS"
    exit 1
fi

echo "tool4d=$tool4d_bin" >> $GITHUB_OUTPUT
