#!/bin/bash

# This script processes FASTQ files to generate quality reports and visualizations with FASTQC.
# Usage: ./reads_quality.sh <forward_fastq> <reverse_fastq> <output_directory>
if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <forward_fastq> <reverse_fastq> <output_directory>"
    exit 1
fi

FORWARD_FASTQ=$1
REVERSE_FASTQ=$2
OUTPUT_DIR=$3

# Check if the output directory exists, if not create it
if [ ! -d "$OUTPUT_DIR" ]; then
    mkdir -p "$OUTPUT_DIR"
fi

# Load the FASTQC module (if using a module system)
module load fastqc

# Run FASTQC on the forward and reverse FASTQ files
fastqc -o "$OUTPUT_DIR" "$FORWARD_FASTQ" "$REVERSE_FASTQ"
