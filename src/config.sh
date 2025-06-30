#!/bin/bash

# ======================== Configuration for ROOT_PATH =======================
# Verify that ROOT_PATH is set
if [ -z "${ROOT_PATH}" ]; then
  echo "ROOT_PATH is not set. Please set it before running this script."
  exit 1
fi

# Define the path to the source directory
SRC_DIR="${ROOT_PATH}/src"

# Verify that SRC_PATH is a valid directory
SRC_PATH="${ROOT_PATH}/src"
if [ ! -d "${SRC_PATH}" ]; then
  echo "Source path does not exist: ${SRC_PATH}"
  exit 1
fi
export SRC_PATH

# ====================== Configuration for Workflow Logs ======================

# Create logs directory if it doesn't exist
mkdir -p "${ROOT_PATH}/logs"

# Define the log file path
LOG_FILE="${ROOT_PATH}/logs/workflow.log"
LOG_COMMANDS_FILE="${ROOT_PATH}/logs/commands.log"

# Create or clear the log files
> "${LOG_FILE}"
> "${LOG_COMMANDS_FILE}"

# ====================== Configuration for Data Directory ======================

DATA_PATH="${ROOT_PATH}/data"
# Create data directory if it doesn't exist
mkdir -p "${DATA_PATH}"

RAW_DATA_PATH="${DATA_PATH}/raw"
RAW_FORWARD_PATH="${DATA_PATH}/raw_forward"
RAW_REVERSE_PATH="${DATA_PATH}/raw_reverse"

PROCESSED_DATA_PATH="${DATA_PATH}/processed"
mkdir -p "${PROCESSED_DATA_PATH}"

FASTQC_PATH="${PROCESSED_DATA_PATH}/fastqc"
FASTQC_RAW_ANALYSIS_PATH="${FASTQC_PATH}/raw_analysis"
FASTQC_PROCESSED_ANALYSIS_PATH="${FASTQC_PATH}/processed_analysis"
mkdir -p "${FASTQC_RAW_ANALYSIS_PATH}"
mkdir -p "${FASTQC_PROCESSED_ANALYSIS_PATH}"

export FASTQC_PATH
export FASTQC_RAW_ANALYSIS_PATH
export FASTQC_PROCESSED_ANALYSIS_PATH


# ====================== Configuration for Workflow Tools ======================


# Define the path to the src/read_contents.sh script
READ_CONTENTS_FILE="${SRC_DIR}/read_contents.sh"
FASTQ_QUALITY_SH="${SRC_PATH}/fastq_quality.sh"




