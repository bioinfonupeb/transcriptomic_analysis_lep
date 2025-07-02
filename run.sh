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
#    echo "Executing setup command: ${SETUP_CMD}"
    eval "${SETUP_CMD}" || { echo "Failed to execute setup script"; exit 1; }
else
    echo "Error: ./src/setup.sh not found at: ${SETUP_FILE}"
    exit 1
fi

# Load config_docker.sh file for Docker paths and variables
source ./src/setup_docker.sh

#echo "DOCKER_VAR[\"DOCKER_RUN_PREFIX\"]"
#echo "${DOCKER_VAR["DOCKER_RUN_PREFIX"]}"


## Define the log file
#LOG_FILE="${OUTPUT_DIR}/pipeline.log"
## Redirect stdout and stderr to the log file
#exec > >(tee -i "${LOG_FILE}") 2>&1

# Print the start time
echo "Starting pipeline for sample: ${SAMPLE_NAME} at $(date)"


FASTQ_DIR=${PATHS["SAMPLE_DIR"]}

R1=${PATHS["RAW_R1"]}
R2=${PATHS["RAW_R2"]}
QC_FASTQC_RAW=${PATHS["QC_FASTQC_RAW"]}

# Check if the output directory exists, if not create it
if [ ! -d "$QC_FASTQC_RAW" ]; then
  echo "Output directory does not exist. Creating $QC_FASTQC_RAW..."
  mkdir -p "$QC_FASTQC_RAW"
fi

# =========================================================
# Step 1: Quality Control using FastQC and Trimmomatic
# =========================================================

MAPPED_FORWARD_FASTQ=$(echo "$R1" | sed "s|${PATHS["BASE_DIR_INPUT"]}|/raw|")
MAPPED_REVERSE_FASTQ=$(echo "$R2" | sed "s|${PATHS["BASE_DIR_INPUT"]}|/raw|")
MAPPED_RAW_FASTQC_OUTPUT_DIR=$(echo "$QC_FASTQC_RAW" | sed "s|$FASTQ_DIR|/data|")

# >>> Run FastQC on the raw FASTQ files
source ${PATHS["SRC"]}/fastq_quality.sh "${MAPPED_FORWARD_FASTQ}" "${MAPPED_REVERSE_FASTQ}" "${MAPPED_RAW_FASTQC_OUTPUT_DIR}"

# >>> Run Trimmomatic for quality trimming
MAPPED_TRIMMED_OUTPUT_DIR=$(echo "${PATHS["TRIMMED"]}" | sed "s|$FASTQ_DIR|/data|")

source ${PATHS["SRC"]}/trimming.sh "${MAPPED_FORWARD_FASTQ}" "${MAPPED_REVERSE_FASTQ}" "${MAPPED_OUTPUT_DIR}"

# >>> Run FastQC on the trimmed FASTQ files
QC_FASTQC_TRIMMED=${PATHS["QC_FASTQC_TRIMMED"]}
if [ ! -d "$QC_FASTQC_TRIMMED" ]; then
  echo "Output directory does not exist. Creating $QC_FASTQC_TRIMMED..."
  mkdir -p "$QC_FASTQC_TRIMMED"
fi
MAPPED_TRIMMED_FORWARD_FASTQ=$(echo "${MAPPED_TRIMMED_OUTPUT_DIR}/trimmed_forward.fastq.gz")
MAPPED_TRIMMED_REVERSE_FASTQ=$(echo "${MAPPED_TRIMMED_OUTPUT_DIR}/trimmed_reverse.fastq.gz")
MAPPED_TRIMMED_FASTQC_OUTPUT_DIR=$(echo "$QC_FASTQC_TRIMMED" | sed "s|$FASTQ_DIR|/data|")

source ${PATHS["SRC"]}/fastq_quality.sh \
 "${MAPPED_TRIMMED_FORWARD_FASTQ}" \
 "${MAPPED_TRIMMED_REVERSE_FASTQ}" \
 "${MAPPED_TRIMMED_FASTQC_OUTPUT_DIR}"

  