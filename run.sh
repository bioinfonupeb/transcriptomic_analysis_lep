#!/bin/bash

# This script processes two FASTQ files and execute a transcriptome analysis pipeline.
# Usage: ./run.sh <sample_name> <forward_fastq> <reverse_fastq>

if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <sample_name> <forward_fastq> <reverse_fastq>"
    exit 1
fi

# Assign arguments to variables
SAMPLE_NAME=$1
FORWARD_FASTQ=$2
REVERSE_FASTQ=$3


# Setup the environment and load the variables
SETUP_FILE="${ROOT_PATH}/src/setup.sh"

# Check if the config.sh file exists
if [ -f "${SETUP_FILE}" ]; then
    echo "Loading configuration from ${SETUP_FILE}"
    source "${SETUP_FILE}"

    # Execute the ./src/setup.sh script
    SETUP_CMD="setup_analysis_structure ${SAMPLE_NAME} ${FORWARD_FASTQ} ${REVERSE_FASTQ}"
    echo "Executing setup command: ${SETUP_CMD}"
    eval "${SETUP_CMD}" || { echo "Failed to execute setup script"; exit 1; }
else
    echo "Error: ./src/setup.sh not found at: ${SETUP_FILE}"
    exit 1
fi


source ./src/config_docker.sh



## Define the log file
#LOG_FILE="${OUTPUT_DIR}/pipeline.log"
## Redirect stdout and stderr to the log file
#exec > >(tee -i "${LOG_FILE}") 2>&1

# Print the start time
echo "Starting pipeline for sample: ${SAMPLE_NAME} at $(date)"

# Step 1: Quality Control using FastQC
MAPPED_FORWARD_FASTQ=$(echo "$FORWARD_FASTQ" | sed "s|$FASTQ_DIR|/input|")
MAPPED_REVERSE_FASTQ=$(echo "$REVERSE_FASTQ" | sed "s|$FASTQ_DIR|/input|")
MAPPED_OUTPUT_DIR=$(echo "$FASTQC_RAW_ANALYSIS_PATH" | sed "s|$ROOT_PATH|/data|")
echo "========================================================"
echo $OUTPUT_DIR
echo $FASTQC_RAW_ANALYSIS_PATH
echo $MAPPED_OUTPUT_DIR
echo "========================================================"

bash "${SRC_PATH}/fastq_quality.sh" "${MAPPED_FORWARD_FASTQ}" "${MAPPED_REVERSE_FASTQ}" "${MAPPED_OUTPUT_DIR}"