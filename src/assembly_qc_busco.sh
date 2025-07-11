#!/bin/bash

# This script runs BUSCO on the assembly to assess its completeness.

if [ "$#" -ne 3 ]; then
    echo "Usage: assembly_qc_busco.sh <assembly.fasta> <busco_out> [<busco_lineage>]"
    exit 1
fi


# Define Docker image
DOCKER_IMAGE="ezlabgva/busco:v5.8.2_cv1"

# Assign input parameters to variables
ASSEMBLY="${1:-${PATHS["TRINITY_ASSEMBLY_FASTA"]}}"
BUSCO_OUT="${2:-${PATHS["ASSEMBLY_QC_BUSCO"]}}"
BUSCO_PLOT="${3:-${PATHS["ASSEMBLY_QC_BUSCO_PLOT"]}}"
BUSCO_LINEAGE="${4:-arthropoda_odb10}"
EXEC=${5:-1}  # Default to 1 if not provided (meaning execute)

SAMPLE_DIR=$PATHS["SAMPLE_DIR"]

# Run BUSCO using Docker
BUSCO_CMD="busco -i $ASSEMBLY -o $BUSCO_OUT -l $BUSCO_LINEAGE -m transcriptome --cpu 16"
if [ "$EXEC" -eq 0 ]; then
    echo "SKIPPING command for Assembly QC with BUSCO."
else
  run_docker_command "$DOCKER_IMAGE" "$BUSCO_CMD" "Assembly QC - BUSCO"
fi


# Copy BUSCO output files to the specified directory
COPY_CMD="sh -c \"cp $BUSCO_OUT/short_summary.*.txt $BUSCO_PLOT\""
if [ "$EXEC" -eq 0 ]; then
    echo "SKIPPING copying BUSCO files."
else
    run_docker_command "$DOCKER_IMAGE" "$COPY_CMD" "Assembly QC - Copying BUSCO files"
fi

# Generate BUSCO plot using the short summary file
BUSCO_PLOT_CMD="generate_plot.py -wd $BUSCO_PLOT"
if [ "$EXEC" -eq 0 ]; then
    echo "SKIPPING BUSCO plot generation."
else
    run_docker_command "$DOCKER_IMAGE" "$BUSCO_PLOT_CMD" "Assembly QC - BUSCO Plot"
fi
