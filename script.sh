#!/bin/bash

VERSION="0.6.7"
BASE_DIR="$HOME/Desktop"
PROJECT_DIR="$HOME/src/incore-labs/fastroll"
RUST_LOG_MODULES="fr_pvm_core::interpreter=debug,fr_pvm_interface::invoke=debug,fr_pvm_host::host_functions=debug"
NUM_BLOCKS=100

TEST_SUITES=(
    # "fallback"
    # "safrole"
    # "storage"
    "storage_light"
    # "preimages"
    "preimages_light"
)

for test_suite in "${TEST_SUITES[@]}"; do
    LOG_DIR="${BASE_DIR}/${test_suite}-${VERSION}"
    RAW_LOG_DIR="${BASE_DIR}/raw-${test_suite}-${VERSION}"
    mkdir -p "$LOG_DIR" "$RAW_LOG_DIR"
    echo "Running ${test_suite} tests..."

    for i in $(seq 1 $NUM_BLOCKS); do
        BLOCK_NUM=$(printf "%08d" "$i")
        TEST_NAME="${test_suite}_${BLOCK_NUM}"
        RAW_LOG_FILE="${RAW_LOG_DIR}/${BLOCK_NUM}.log"
        LOG_FILE="${LOG_DIR}/${BLOCK_NUM}.log"

        echo "Writing logs to ${LOG_FILE}"

        cd "$PROJECT_DIR" && RUST_LOG="$RUST_LOG_MODULES" cargo nextest run "$TEST_NAME" --success-output immediate-final 2>"$RAW_LOG_FILE"
        grep "DEBUG" "$RAW_LOG_FILE" > "$LOG_FILE"

        # Delete empty files
        if [ ! -s "$LOG_FILE" ]; then
            echo "Deleting empty log file: $LOG_FILE"
            rm "$LOG_FILE"
        fi
    done
done
