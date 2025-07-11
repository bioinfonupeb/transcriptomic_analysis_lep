#!/bin/bash

# This script uses trimmed fastq files to run de novo assembly with Trinity.
# Usage: ./assembly.sh

# Define original paths
SAMPLE_DIR=${PATHS["SAMPLE_DIR"]}
TRINITY_ASSEMBLY_DIR=${PATHS["TRINITY_ASSEMBLY_DIR"]}
TRIMMED_R1="${PATHS["TRIMMED_R1"]}"
TRIMMED_R2="${PATHS["TRIMMED_R2"]}"
EXEC=${5:-1}  # Default to 1 if not provided (meaning execute)

# Check if trimmed fastq files exist
if [ ! -f "$TRIMMED_R1" ] || [ ! -f "$TRIMMED_R2" ]; then
    echo "Error: One or both of the trimmed fastq files do not exist."
    echo "TRIMMED_R1: $TRIMMED_R1"
    echo "TRIMMED_R2: $TRIMMED_R2"
    exit 1
fi

# Create the Trinity directory if it does not exist for assembly output
if [ ! -d "$TRINITY_ASSEMBLY_DIR" ]; then
    mkdir -p "$TRINITY_ASSEMBLY_DIR"
fi


# Define mapped paths for volume mounting in Docker
TRIMMED_R1=$(echo "$TRIMMED_R1" | sed "s|$SAMPLE_DIR|/data|")
TRIMMED_R2=$(echo "$TRIMMED_R2" | sed "s|$SAMPLE_DIR|/data|")
TRINITY_ASSEMBLY_DIR=$(echo "$TRINITY_ASSEMBLY_DIR" | sed "s|$SAMPLE_DIR|/data|")

# Define Docker image
DOCKER_IMAGE="trinityrnaseq/trinityrnaseq:latest"

# =====================================================================
# =====================================================================
# Perform the assembly using "Trinity"
TRINITY_CMD="Trinity --seqType fq --max_memory 50G --CPU 16 \
--output ${TRINITY_ASSEMBLY_DIR} \
--left ${TRIMMED_R1} \
--right ${TRIMMED_R2}"

if [ "$EXEC" -eq 0 ]; then
    echo "SKIPPING command for Assembly with Trinity."
else
    run_docker_command "$DOCKER_IMAGE" "$TRINITY_CMD" "Trinity Assembly"
fi



# =====================================================================
# =====================================================================
# Perform assembly quality control using "TrinityStats"
TRINITY_STATS="/usr/local/bin/util/TrinityStats.pl"
STATS_FILE=${PATHS["ASSEMBLY_QC_TRINITY_STATS"]}
MAP_ASSEMBLY_FASTA=$(echo "${PATHS["TRINITY_ASSEMBLY_FASTA"]}" | sed "s|$SAMPLE_DIR|/data|")
TRINITY_STATS_CMD="$TRINITY_STATS $MAP_ASSEMBLY_FASTA >> $STATS_FILE"

if [ "$EXEC" -eq 0 ]; then
    echo "SKIPPING command for Assembly QC with Trinity Stats."
else
    run_docker_command "$DOCKER_IMAGE" "$TRINITY_STATS_CMD" "Assembly QC - Trinity Stats"
fi
