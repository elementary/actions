#!/bin/bash

dir=$1
conf=$2
fail=$3

args=()

if [[ $conf != "" ]]; then
    args+=("-c")
    args+=("$conf")
fi

if [[ $fail == "false" ]]; then
    args+=("-z")
fi

if [[ $dir != "" ]]; then
    args+=("$dir")
fi

io.elementary.vala-lint "${args[@]}"