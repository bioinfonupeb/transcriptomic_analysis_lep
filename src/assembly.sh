#!/bin/bash

# This script uses trimmed fastq files to run de novo assembly with Trinity.
# Usage: ./assembly.sh <fastq_forward> <fastq_reverse> <output_dir>

if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <fastq_forward> <fastq_reverse> <output_dir>"
    exit 1
fi

FASTQ_FORWARD=$1
FASTQ_REVERSE=$2
OUTPUT_DIR=$3

DOCKER_IMAGE="trinityrnaseq/trinityrnaseq:latest"

TRINITY_CMD="Trinity --seqType fq --max_memory 50G --CPU 16 --output $OUTPUT_DIR --left $FASTQ_FORWARD --right $FASTQ_REVERSE"

run_docker_command "$DOCKER_IMAGE" "$TRINITY_CMD"