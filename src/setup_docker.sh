#!/bin/bash

# ======================= Configuration for DOCKER =======================

# Verfify if Docker is installed
if ! command -v docker &> /dev/null; then
  echo "Docker is not installed. Please install Docker before running this script."
  exit 1
fi

# If PATHS["RAW_DATA"], PATHS["SAMPLE_DIR"] and PATHS["SRC"] variables exists
if [[ -z "${PATHS["RAW_DATA"]}" || -z "${PATHS["SAMPLE_DIR"]}" || -z "${PATHS["SRC"]}" ]]; then
  echo "Please set PATHS['RAW_DATA'], PATHS['SAMPLE_DIR'], and PATHS['SRC'] in your environment."
  exit 1
fi


# Define the Docker run prefix command for workflow tools
DOCKER_RUN_PREFIX="docker run --rm -v ${ROOT_PATH}:/data -v ${SRC_PATH}:/src -v ${FASTQ_DIR}:/input -w /data"
export DOCKER_RUN_PREFIX


# Define a function to convert absolute paths to relative paths to use in Docker volumes and retunrs the relative path
# Usage example:
# relative_path=$(convert_to_relative_path "/absolute/path/to/dir" "/root/path")
convert_to_relative_path(abs_path, root_path) {
  local abs_path="$1"
  local root_path="$2"

  # Remove trailing slashes
  abs_path="${abs_path%/}"
  root_path="${root_path%/}"

  # Get the relative path
  local relative_path=$(realpath --relative-to="$root_path" "$abs_path")

  echo "$relative_path"
}
export -f convert_to_relative_path