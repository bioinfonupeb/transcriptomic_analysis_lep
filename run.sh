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

# Print the start time
echo "Starting pipeline for sample: ${SAMPLE_NAME} at $(date)"

# Setup the paths from the PATHS associative array
SAMPLE_DIR=${PATHS["SAMPLE_DIR"]}
R1=${PATHS["RAW_R1"]}
R2=${PATHS["RAW_R2"]}
QC_FASTQC_RAW=${PATHS["QC_FASTQC_RAW"]}

# Check if the output directory exists, if not create it
if [ ! -d "$QC_FASTQC_RAW" ]; then
  echo "Output directory does not exist. Creating $QC_FASTQC_RAW..."
  mkdir -p "$QC_FASTQC_RAW"
fi

# ==========================================================
# Step 1: Quality Control using FastQC and Trimmomatic
# ==========================================================

# Setup the paths for the raw FASTQ files and output directory
MAPPED_FORWARD_FASTQ=$(echo "$R1" | sed "s|${PATHS["BASE_DIR_INPUT"]}|/raw|")
MAPPED_REVERSE_FASTQ=$(echo "$R2" | sed "s|${PATHS["BASE_DIR_INPUT"]}|/raw|")
MAPPED_RAW_FASTQC_OUTPUT_DIR=$(echo "$QC_FASTQC_RAW" | sed "s|$SAMPLE_DIR|/data|")

# >>> RUN: FastQC on the raw FASTQ files
source ${PATHS["SRC"]}/fastq_quality.sh "${MAPPED_FORWARD_FASTQ}" "${MAPPED_REVERSE_FASTQ}" "${MAPPED_RAW_FASTQC_OUTPUT_DIR}"

# ==========================================================

# Setup the paths for the trimmed FASTQ files and output directory
TRIMMED_DIR=${PATHS["TRIMMED"]}
if [ ! -d "$TRIMMED_DIR" ]; then
  echo "Output directory does not exist. Creating $TRIMMED_DIR..."
  mkdir -p "$TRIMMED_DIR"
fi

MAPPED_TRIMMED_OUTPUT_DIR=$(echo "$TRIMMED_DIR" | sed "s|$SAMPLE_DIR|/data|")

# >>> RUN: Trimmomatic to trim the FASTQ files
source ${PATHS["SRC"]}/trimming.sh "${MAPPED_FORWARD_FASTQ}" "${MAPPED_REVERSE_FASTQ}" "${MAPPED_TRIMMED_OUTPUT_DIR}"

# ==========================================================

# Setup the paths for the trimmed FASTQ files and FastQC output directory
QC_FASTQC_TRIMMED=${PATHS["QC_FASTQC_TRIMMED"]}
if [ ! -d "$QC_FASTQC_TRIMMED" ]; then
  echo "Output directory does not exist. Creating $QC_FASTQC_TRIMMED..."
  mkdir -p "$QC_FASTQC_TRIMMED"
fi
MAPPED_TRIMMED_FORWARD_FASTQ=$(echo "${MAPPED_TRIMMED_OUTPUT_DIR}/trimmed_forward.fastq.gz")
MAPPED_TRIMMED_REVERSE_FASTQ=$(echo "${MAPPED_TRIMMED_OUTPUT_DIR}/trimmed_reverse.fastq.gz")
MAPPED_TRIMMED_FASTQC_OUTPUT_DIR=$(echo "$QC_FASTQC_TRIMMED" | sed "s|$SAMPLE_DIR|/data|")

# >>> RUN: FastQC on the trimmed FASTQ files
source ${PATHS["SRC"]}/fastq_quality.sh \
# "${MAPPED_TRIMMED_FORWARD_FASTQ}" \
# "${MAPPED_TRIMMED_REVERSE_FASTQ}" \
# "${MAPPED_TRIMMED_FASTQC_OUTPUT_DIR}"

# ==========================================================


# ==========================================================
# Step 2: De Novo Transcriptome Assembly
# ==========================================================

# Setup the paths for the assembly output directories
ASSEMBLY_DIR=${PATHS["ASSEMBLY"]}
TRINITY_ASSEMBLY_DIR=${PATHS["TRINITY_ASSEMBLY_DIR"]}
MAPPED_ASSEMBLY_OUTPUT_DIR=$(echo "$ASSEMBLY_DIR" | sed "s|$SAMPLE_DIR|/data|")
MAPPED_TRINITY_ASSEMBLY_DIR=$(echo "$TRINITY_ASSEMBLY_DIR" | sed "s|$SAMPLE_DIR|/data|")

## >>> RUN: Trinity assembly
source ${PATHS["SRC"]}/assembly.sh \
# "${MAPPED_TRIMMED_FORWARD_FASTQ}" \
# "${MAPPED_TRIMMED_REVERSE_FASTQ}" \
# "${MAPPED_ASSEMBLY_OUTPUT_DIR}"   \
# "${MAPPED_TRINITY_ASSEMBLY_DIR}"

TRINITY_FASTA=${PATHS["TRINITY_ASSEMBLY_FASTA"]}

# ==========================================================

# ==========================================================
# Step 3: Assembly Quality Control
# ==========================================================

# Setup the paths for the BUSCO output directory
MAPPED_TRINITY_FASTA=$(echo "$TRINITY_FASTA" | sed "s|$SAMPLE_DIR|/data|")
ASSEMBLY_QC_BUSCO=${PATHS["ASSEMBLY_QC_BUSCO"]}
if [ ! -d "$ASSEMBLY_QC_BUSCO" ]; then
  echo "Output directory does not exist. Creating $ASSEMBLY_QC_BUSCO..."
  mkdir -p "$ASSEMBLY_QC_BUSCO"
fi
MAPPED_BUSCO_OUTPUT_DIR=$(echo "$ASSEMBLY_QC_BUSCO" | sed "s|$SAMPLE_DIR|.|")

BUSCO_PLOT=${PATHS["ASSEMBLY_QC_BUSCO_PLOT"]}
if [ ! -d "$BUSCO_PLOT" ]; then
  echo "Output directory does not exist. Creating $BUSCO_PLOT..."
  mkdir -p "$BUSCO_PLOT"
fi
MAPPED_BUSCO_PLOT=$(echo "$BUSCO_PLOT" | sed "s|$SAMPLE_DIR|.|")

# >>> RUN: BUSCO for assembly quality control
source ${PATHS["SRC"]}/assembly_qc_busco.sh \
#"${MAPPED_TRINITY_FASTA}" \
#"${MAPPED_BUSCO_OUTPUT_DIR}" \
#"${MAPPED_BUSCO_PLOT}"
 
# ==========================================================

source ${PATHS["SRC"]}/assembly_qc_transrate.sh


# ==========================================================
 