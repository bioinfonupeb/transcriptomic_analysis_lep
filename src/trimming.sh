#!/bin/bash

# This script trimm FASTQ files to generate good quality reads using FastQC and Trimmomatic.
# Usage: ./trimming.sh <forward_fastq> <reverse_fastq> <output_directory>

if [ "$#" -lt 3 ]; then
  echo "Usage: $0 <forward_fastq> <reverse_fastq> <output_directory>"
  exit 1
fi

FORWARD_FASTQ=$1
REVERSE_FASTQ=$2
OUTPUT_DIR=$3
EXEC=${4:-1}  # Default to 1 if not provided (meaning execute)

TR1=${PATHS["TRIMMED_R1"]}
TR2=${PATHS["TRIMMED_R2"]}
UR1="${OUTPUT_DIR}/unpaired_forward.fastq.gz"
UR2="${OUTPUT_DIR}/unpaired_reverse.fastq.gz"

# Define Docker image and container name
DOCKER_IMAGE="staphb/trimmomatic:latest"
CONTAINER_NAME="trimmomatic_container"


DOCKER_RUN_PREFIX="${DOCKER_VAR["DOCKER_RUN_PREFIX"]}"


TR1=$(echo "$TR1" | sed "s|$SAMPLE_DIR|/data|")
TR2=$(echo "$TR2" | sed "s|$SAMPLE_DIR|/data|")
UR1=$(echo "$UR1" | sed "s|$SAMPLE_DIR|/data|")
UR2=$(echo "$UR2" | sed "s|$SAMPLE_DIR|/data|")

# Construct the run command for Trimmomatic
DOCKER_RUN_CMD="trimmomatic PE -threads 10 -phred33 \
  $FORWARD_FASTQ $REVERSE_FASTQ \
  $TR1 $UR1 $TR2 $UR2 \
  LEADING:3 TRAILING:3 SLIDINGWINDOW:4:15 MINLEN:36"

# Run the Docker command
if [ "$EXEC" -eq 0 ]; then
  echo "SKIPPING command for Trimming Raw Reads with Trimmomatic."
else
  echo "PORRRRA"
  run_docker_command "$DOCKER_IMAGE" "$DOCKER_RUN_CMD" "Trimming with Trimmomatic."
fi
