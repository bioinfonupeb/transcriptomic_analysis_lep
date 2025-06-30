#!/bin/bash

# This script processes FASTQ files to generate quality reports and visualizations with FASTQC.
# Usage: ./fastq_quality.sh <forward_fastq> <reverse_fastq> <output_directory>
if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <forward_fastq> <reverse_fastq> <output_directory>"
    exit 1
fi

FORWARD_FASTQ=$1
REVERSE_FASTQ=$2
OUTPUT_DIR=$3

# Check if the output directory exists, if not create it
if [ ! -d "$OUTPUT_DIR" ]; then
  echo "Output directory does not exist. Creating $OUTPUT_DIR..."
  mkdir -p "$OUTPUT_DIR"
fi


# Define Docker image and container name
DOCKER_IMAGE="biocontainers/fastqc:v0.11.9_cv8"
CONTAINER_NAME="fastqc_container"

# If DOCKER_RUN_PREFIX is set, change the command to run in Docker
if [ -n "${DOCKER_RUN_PREFIX}" ]; then
#    # Change the paths to map to the data directory in the Docker container
#    MAPPED_FORWARD_FASTQ=$(echo "$FORWARD_FASTQ" | sed "s|$ROOT_PATH|data|")
#    MAPPED_REVERSE_FASTQ=$(echo "$REVERSE_FASTQ" | sed "s|$ROOT_PATH|data|")
#    MAPPED_OUTPUT_DIR=$(echo "$OUTPUT_DIR" | sed "s|$ROOT_PATH|data|")

    FASTQC_PREFIX="${DOCKER_RUN_PREFIX} ${DOCKER_IMAGE} fastqc"

    # Construct the run command for FASTQC in Docker
    FASTQC_CMD="${FASTQC_PREFIX} -o ${OUTPUT_DIR} ${FORWARD_FASTQ} ${REVERSE_FASTQ}"
    echo "Running FASTQC in Docker with command:"
    echo "$FASTQC_CMD"
    eval "${FASTQC_CMD}"
else
    # Construct the run command for FASTQC
    FASTQC_CMD="fastqc -o ${OUTPUT_DIR} ${FORWARD_FASTQ} ${REVERSE_FASTQ}"
    echo "Running FASTQC with command: $FASTQC_CMD"
    eval "${FASTQC_CMD}"
fi

# Check if FASTQC ran successfully
if [ $? -ne 0 ]; then
    echo "FASTQC failed. Please check the input files and try again."
    exit 1
fi
