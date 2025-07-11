#!/bin/bash

# This script processes FASTQ files to generate quality reports and visualizations with FASTQC.
# Usage: ./fastq_quality.sh <forward_fastq> <reverse_fastq> <output_directory>
if [ "$#" -lt 3 ]; then
    echo "Usage: $0 <forward_fastq> <reverse_fastq> <output_directory> [skip]"
    exit 1
fi

FORWARD_FASTQ=$1
REVERSE_FASTQ=$2
OUTPUT_DIR=$3
EXEC=${4:-1}  # Default to 1 if not provided (meaning execute)

echo "EXEC" "$EXEC"


# Define Docker image and container name
DOCKER_IMAGE="biocontainers/fastqc:v0.11.9_cv8"
CONTAINER_NAME="fastqc_container"

# Construct the run command for FASTQC in Docker
FASTQC_CMD="fastqc -o ${OUTPUT_DIR} ${FORWARD_FASTQ} ${REVERSE_FASTQ}"
if [ $EXEC -eq 0 ]; then
    echo "SKIPPING command for Raw Reads QC with FASTQC."
else
    run_docker_command "${DOCKER_IMAGE}" "${FASTQC_CMD}" "Raw Reads QC - FASTQC"
    # Check if FASTQC ran successfully
    if [ $? -ne 0 ]; then
        echo "FASTQC failed. Please check the input files and try again."
        exit 1
    fi
fi



