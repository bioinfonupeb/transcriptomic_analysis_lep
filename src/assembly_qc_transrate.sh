

# ==========================================================================
# TransRate: assembly quality analysis.
# https://hibberdlab.com/transrate/
# ==========================================================================

echo "Performing assembly quality analysis with TransRate..."

# Directory for RSEM and Bowtie2 QC
SAMPLE_DIR=${PATHS["SAMPLE_DIR"]}
TRANSRATE_ASSEMBLY=${PATHS["TRANSRATE_ASSEMBLY"]}
TRANSRATE_READS=${PATHS["TRANSRATE_READS"]}
ASSEMBLY_FILE=${PATHS["TRINITY_ASSEMBLY_FASTA"]}
R1_FILE=${PATHS["TRIMMED_R1"]}
R2_FILE=${PATHS["TRIMMED_R2"]}

THREADS=PARAMS["THREADS"]


# Check if the directory exists and create it if not
if [ ! -d "$TRANSRATE_ASSEMBLY" ]; then
    mkdir -p "$TRANSRATE_ASSEMBLY"
fi

if [ ! -d "$TRANSRATE_READS" ]; then
    mkdir -p "$TRANSRATE_READS"
fi

# Define Docker image
DOCKER_IMAGE="arnaudmeng/transrate:1.0.3"

# Transform the path to mount in Docker
MAP_QC_DIR_A=$(echo "$TRANSRATE_ASSEMBLY" | sed "s|$SAMPLE_DIR|/data|")
MAP_QC_DIR_R=$(echo "$TRANSRATE_READS" | sed "s|$SAMPLE_DIR|/data|")
MAP_ASSEMBLY=$(echo "$ASSEMBLY_FILE" | sed "s|$SAMPLE_DIR|/data|")
MAP_R1=$(echo "$R1_FILE" | sed "s|$SAMPLE_DIR|/data|")
MAP_R2=$(echo "$R2_FILE" | sed "s|$SAMPLE_DIR|/data|")

# Analize the assembly file for contig metrics
# https://hibberdlab.com/transrate/metrics.html#contig-metrics
CMD="transrate --assembly $MAP_ASSEMBLY --output $MAP_QC_DIR_A --threads 12"

run_docker_command "$DOCKER_IMAGE" "$CMD" "TransRate: contig metrics for assembly quality analysis."

# Analize the assembly file using read evidence
# https://hibberdlab.com/transrate/metrics.html#read-mapping-metrics
CMD="transrate --assembly $MAP_ASSEMBLY --left $MAP_R1 --right $MAP_R2 --output $MAP_QC_DIR_R --threads 12"
run_docker_command "$DOCKER_IMAGE" "$CMD" "TransRate: read evidence for assembly quality analysis."