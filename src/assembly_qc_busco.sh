#!/bin/bash

# This script runs BUSCO on the assembly to assess its completeness.

if [ "$#" -ne 3 ]; then
    echo "Usage: assembly_qc_busco.sh <assembly.fasta> <busco_out> [<busco_lineage>]"
    exit 1
fi


# Define Docker image
DOCKER_IMAGE="ezlabgva/busco:v5.8.2_cv1"

# Assign input parameters to variables
ASSEMBLY="$1"
BUSCO_OUT="$2"
BUSCO_PLOT="$3"
BUSCO_LINEAGE="${4:-arthropoda_odb10}"

SAMPLE_DIR=$PATHS["SAMPLE_DIR"]

# Run BUSCO using Docker
BUSCO_CMD="busco -i $ASSEMBLY -o $BUSCO_OUT -l $BUSCO_LINEAGE -m transcriptome --cpu 16"
run_docker_command "$DOCKER_IMAGE" "$BUSCO_CMD" "Assembly QC - BUSCO"

# Copy BUSCO output files to the specified directory
COPY_CMD="sh -c \"cp $BUSCO_OUT/short_summary.*.txt $BUSCO_PLOT\""
run_docker_command "$DOCKER_IMAGE" "$COPY_CMD" "Assembly QC - Copying BUSCO files"

# Generate BUSCO plot using the short summary file
BUSCO_PLOT_CMD="generate_plot.py -wd $BUSCO_PLOT"
run_docker_command "$DOCKER_IMAGE" "$BUSCO_PLOT_CMD" "Assembly QC - BUSCO Plot"
