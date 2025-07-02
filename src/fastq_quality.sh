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


# Define Docker image and container name
DOCKER_IMAGE="biocontainers/fastqc:v0.11.9_cv8"
CONTAINER_NAME="fastqc_container"

# Construct the run command for FASTQC in Docker
FASTQC_CMD="fastqc -o ${OUTPUT_DIR} ${FORWARD_FASTQ} ${REVERSE_FASTQ}"
run_docker_command "${DOCKER_IMAGE}" "${FASTQC_CMD}"


# Check if FASTQC ran successfully
if [ $? -ne 0 ]; then
    echo "FASTQC failed. Please check the input files and try again."
    exit 1
fi
