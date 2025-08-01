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

declare -gA DOCKER_VAR  # Global associative array to store all paths

# Define the Docker run prefix command for workflow tools
DOCKER_VAR["DOCKER_RUN_PREFIX"]="docker run --rm \
-v ${PATHS["SAMPLE_DIR"]}:/data \
-v ${PATHS["BASE_DIR_INPUT"]}:/raw \
-v ${PATHS["SRC"]}:/src \
-u $(id -u) \
-w /data"




# Define a function to convert absolute paths to relative paths to use in Docker volumes and retunrs the relative path
# Usage example:
# relative_path=$(convert_to_relative_path "/absolute/path/to/dir" "/root/path")
convert_to_relative_path() {
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

# Define a function to convert relative paths to absolute paths
# Usage example:
# absolute_path=$(convert_to_absolute_path "relative/path/to/dir" "/root/path")
convert_to_absolute_path() {
  local rel_path="$1"
  local root_path="$2"

  # Remove trailing slashes
  rel_path="${rel_path%/}"
  root_path="${root_path%/}"

  # Get the absolute path
  local abs_path=$(realpath "$root_path/$rel_path")

  echo "$abs_path"
}

# Define a function to run a Docker command with the prefix
# Usage example:
# run_docker_command "my_docker_image" "my_command"
run_docker_command() {

  # Verfiy if has exactly 2 arguments
  if [[ $# -lt 2 ]]; then
    local image="$1"
    local command="$2"
  elif [[ $# -eq 3 ]]; then
    local image="$1"
    local command="$2"
    local log_tag="$3"
  else
    echo "Usage: run_docker_command <image> <command> [log_tag]"
    return 1
  fi


  # Check if the image is provided
  if [[ -z "$image" ]]; then
    echo "Error: Docker image name is required."
    return 1
  fi

  echo "========================= Running Docker Command ========================"
  echo "$command"
  echo "Using Docker image: $image"
  echo "With Docker run prefix: ${DOCKER_VAR["DOCKER_RUN_PREFIX"]} $image"
  echo "=========================================================================="


  # Log command to PATHS["LOG_CMD"]
  LOG=${PATHS["LOG_CMD"]}
  if [[ -n "$LOG" ]]; then
    echo "==========================================================================" >> "$LOG"
    if [[ -z "$log_tag" ]]; then
      echo "> RUN at $(date)" >> "$LOG"
    else
      echo "> RUN \"$log_tag\" at $(date)" >> "$LOG"
    fi
    echo "" >> "$LOG"
    echo "${DOCKER_VAR["DOCKER_RUN_PREFIX"]} $image $command" >> "$LOG"
    echo "" >> "$LOG"
    echo "==========================================================================" >> "$LOG"
  fi

  # Run the Docker command with the prefix
  eval "${DOCKER_VAR["DOCKER_RUN_PREFIX"]} $image $command"
}
export -f run_docker_command