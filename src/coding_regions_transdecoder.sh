#!/bin/bash

# This script is used to run TransDecoder on a set of coding regions assembled with Trinity.

EXEC=${1:-1}  # Default to 1 if not provided (meaning execute)

DOCKER_IMAGE="trinityrnaseq/transdecoder:latest"
CONTAINER_NAME="transdecoder_container"


DOCKER_RUN_PREFIX="${DOCKER_VAR["DOCKER_RUN_PREFIX"]}"

ASSEMBLY_FILE=${PATHS["TRINITY_ASSEMBLY_FASTA"]}

TRANSDECODER_DIR="${PATHS["TRANSDECODER"]}"

DOCKER_CMD="TransDecoder.Predict -t $ASSEMBLY_FILE -O $TRANSDECODER_DIR \
--retain_pfam_hits --retain_blastp_hits --single_best_only"

# Run the Docker command
echo "$DOCKER_RUN_PREFIX" "$DOCKER_IMAGE" "$DOCKER_RUN_CMD"
if [ "$EXEC" -eq 0 ]; then
  echo "SKIPPING command for Finding Coding Regions with TransDecoder."
else
  run_docker_command "$DOCKER_IMAGE" "$DOCKER_CMD" "Finding coding regions with TransDecoder"
fi

