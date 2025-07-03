#!/bin/bash

set -uo pipefail

success=0
retry=10

rm -rf out
mkdir -p out/all out/ok out/fail

export PROTO_LOG="trace"
export MOON_LOG="trace"

for i in $(seq 1 $retry); do
    echo "Run $i/$retry"
    logfile="out/all/run-$i.log"
    (
        find . -type d -name "node_modules" -prune -exec rm -rf {} \;
        find . -type f -name "tsconfig.build.tsbuildinfo" -prune -exec rm -rf {} \;
        find . -type d -name "dist" -prune -exec rm -rf {} \;
        find . -type f -name "tsconfig.lib.tsbuildinfo" -prune -exec rm -rf {} \;
        find . -type d -name "lib" -prune -exec rm -rf {} \;
        rm -rf .moon/cache &&
            moon run demo-app-ko:build
    ) >"$logfile" 2>&1
    if [ $? -eq 0 ]; then
        cp "$logfile" "out/ok/run-$i.log"
        success=$((success + 1))
    else
        cp "$logfile" "out/fail/run-$i.log"
    fi
done

echo "Number of successful runs: $success/$retry"
