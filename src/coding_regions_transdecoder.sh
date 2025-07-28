#!/bin/bash

# This script is used to run TransDecoder on a set of coding regions assembled with Trinity.

EXEC=${1:-1}  # Default to 1 if not provided (meaning execute)

DOCKER_IMAGE="trinityrnaseq/transdecoder:latest"
CONTAINER_NAME="transdecoder_container"


SAMPLE_DIR=${PATHS["SAMPLE_DIR"]}
DOCKER_RUN_PREFIX="${DOCKER_VAR["DOCKER_RUN_PREFIX"]}"

ASSEMBLY_FILE=${PATHS["TRINITY_ASSEMBLY_FASTA"]}
TRANSDECODER_DIR="${PATHS["TRANSDECODER"]}"
mkdir -p "$TRANSDECODER_DIR"

MAP_ASSEMBLY_FILE=$(echo "$ASSEMBLY_FILE" | sed "s|$SAMPLE_DIR|/data|")
MAP_TRANSDECODER_DIR=$(echo "$TRANSDECODER_DIR" | sed "s|$SAMPLE_DIR|/data|")

DOCKER_CMD="TransDecoder.LongOrfs -t $MAP_ASSEMBLY_FILE -O $MAP_TRANSDECODER_DIR"

if [ "$EXEC" -eq 0 ]; then
  echo "SKIPPING command for Finding Long ORFs with TransDecoder."
else
  run_docker_command "$DOCKER_IMAGE" "$DOCKER_CMD" "Finding Long ORFs with TransDecoder"
fi

DOCKER_CMD="TransDecoder.Predict -t $MAP_ASSEMBLY_FILE -O $MAP_TRANSDECODER_DIR \
--retain_pfam_hits --retain_blastp_hits --single_best_only"

if [ "$EXEC" -eq 0 ]; then
  echo "SKIPPING command for Finding Coding Regions with TransDecoder."
else
  run_docker_command "$DOCKER_IMAGE" "$DOCKER_CMD" "Finding coding regions with TransDecoder"
fi

