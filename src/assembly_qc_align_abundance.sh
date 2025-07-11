TRINITY_ALIGN="/usr/local/bin/util/align_and_estimate_abundance.pl"

# =====================================================================
# RSEM and Bowtie2
# =====================================================================

# Perform alignment and abundance estimation using "RSEM and Bowtie2"

# Directory for RSEM and Bowtie2 QC
QC_RSEM_BOWTIE2_DIR=${PATHS["QC_RSEM_BOWTIE2"]}

# Check if the directory exists and create it if not
if [ ! -d "$QC_RSEM_BOWTIE2_DIR" ]; then
    mkdir -p "$QC_RSEM_BOWTIE2_DIR"
fi
# Transform the path to mount in Docker
MAP_RSEM_BOWTIE2=$(echo "$QC_RSEM_BOWTIE2_DIR" | sed "s|$FASTQ_DIR|/data|")
# Perform alignment and abundance estimation using "RSEM and Bowtie2"
TRINITY_ALIGN_CMD="$TRINITY_ALIGN --transcripts $MAP_ASSEMBLY_FASTA \
--left $FASTQ_FORWARD --right $FASTQ_REVERSE \
--output_dir $MAP_RSEM_BOWTIE2 \
--seqType fq --trinity_mode --prep_reference --thread_count 16 \
--est_method RSEM --aln_method bowtie2"

#run_docker_command "$DOCKER_IMAGE" "$TRINITY_ALIGN_CMD" "Assembly QC - Trinity Align with RSEM and Bowtie2"


# =====================================================================
# Salmon
# =====================================================================
# Perform alignment and abundance estimation using "Salmon"


QC_SALMON_DIR="${PATHS["QC_SALMON"]}"
if [ ! -d "$QC_SALMON_DIR" ]; then
    mkdir -p "$QC_SALMON_DIR"
fi
MAP_SALMON=$(echo "$QC_SALMON_DIR" | sed "s|$FASTQ_DIR|/data|")
TRINITY_ALIGN_CMD="$TRINITY_ALIGN --transcripts $MAP_ASSEMBLY_FASTA \
--left $FASTQ_FORWARD --right $FASTQ_REVERSE \
--output_dir $MAP_SALMON \
--seqType fq --trinity_mode --prep_reference --thread_count 16 \
--est_method salmon --aln_method none"

run_docker_command "$DOCKER_IMAGE" "$TRINITY_ALIGN_CMD" "Assembly QC - Trinity Align with Salmon"


# =====================================================================
# =====================================================================