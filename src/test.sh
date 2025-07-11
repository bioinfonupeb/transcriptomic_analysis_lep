#!/bin/bash

# Usage: ./test.sh --config <config_file> --test <test_name>

# Parameters
CONFIG_FILE=""
TEST_NAME=""
# Parse command line arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --config) CONFIG_FILE="$2"; shift ;;
        --test) TEST_NAME="$2"; shift ;;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done
# Check if config file and test name are provided
if [[ -z "$CONFIG_FILE" || -z "$TEST_NAME" ]]; then
    echo "Usage: $0 --config <config_file> --test <test_name>"
    exit 1
fi
# Print the parameters
echo "Config file: $CONFIG_FILE"
echo "Test name: $TEST_NAME"