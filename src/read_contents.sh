#!/bin/bash

# Assessing the Read Content of the Transcriptome Assembly with bowtie2
# Usage: ./read_content.sh <transcriptome.fasta> <read-forward.fastq> <read-reverse.fastq>

if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <transcriptome.fasta> <read-forward.fastq> <read-reverse.fastq>"
    exit 1
fi

TRANSCRIPTOME=$1
READ_FORWARD=$2
READ_REVERSE=$3

# Check if the input files exist
if [ ! -f "$TRANSCRIPTOME" ]; then
    echo "Transcriptome file '$TRANSCRIPTOME' does not exist."
    exit 1
fi
if [ ! -f "$READ_FORWARD" ]; then
    echo "Forward read file '$READ_FORWARD' does not exist."
    exit 1
fi
if [ ! -f "$READ_REVERSE" ]; then
    echo "Reverse read file '$READ_REVERSE' does not exist."
    exit 1
fi

# Define the Bowtie2 index name based on the transcriptome file
BOWTIE2_INDEX="${TRANSCRIPTOME%.fasta}"
# Define command to build bowtie2 index
BUILD_CMD="bowtie2-build -f \"$TRANSCRIPTOME\" \"$BOWTIE2_INDEX\""
# Define command to align reads
ALIGN_CMD="bowtie2 -x \"$BOWTIE2_INDEX\" -1 \"$READ_FORWARD\" -2 \"$READ_REVERSE\" -S \"aligned_reads.sam\" --no-unal"


# Define Docker image and container name
DOCKER_IMAGE="bowtie2/bowtie2"
CONTAINER_NAME="bowtie2_container"

# Check if DOCKER_RUN_PREFIX variable is set
if [ -z "$DOCKER_RUN_PREFIX" ]; then
    DOCKER_RUN_PREFIX=""
fi

BUILD_CMD="${$DOCKER_RUN_PREFIX} ${BUILD_CMD}"
ALIGN_CMD="${$DOCKER_RUN_PREFIX} ${ALIGN_CMD}"

# Echo the command for debugging
echo "Building Bowtie2 index with command: $BUILD_CMD"
echo "$BUILD_CMD" > "$LOG_FILE"

# Execute the build command in BUILD_CMD
eval "$BUILD_CMD"

# Echo the command for debugging
echo "Aligning reads with command: $ALIGN_CMD"
echo "$ALIGN_CMD" > "$LOG_FILE"

# Execute the alignment command in ALIGN_CMD
eval "$ALIGN_CMD"
