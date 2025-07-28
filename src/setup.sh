#!/bin/bash

# Example usage:
# setup_analysis_structure "sample1" "/path/to/sample1_R1.fastq.gz" "/path/to/sample1_R2.fastq.gz" "/analysis_root"

setup_analysis_structure() {
    # Input parameters
    local sample_name="$1"
    local forward_fastq="$2"
    local reverse_fastq="$3"
    local root_dir="${4:-$PWD}"  # Default to current directory if not specified

    echo "=========================="

    # Validate inputs
    if [[ -z "$sample_name" || -z "$forward_fastq" || -z "$reverse_fastq" ]]; then
        echo "Error: Missing required arguments" >&2
        echo "Usage: setup_analysis_structure <sample_name> <forward_fastq> <reverse_fastq> [root_dir]" >&2
        return 1
    fi

    if [[ ! -f "$forward_fastq" || ! -f "$reverse_fastq" ]]; then
        echo "Error: FASTQ files don't exist" >&2
        return 1
    fi

    # Create directory structure
    local base_raw_dir="$(dirname "$(readlink -f "$forward_fastq")")"
    local sample_dir="${root_dir}/processed/${sample_name}"
    local raw_data_dir="${sample_dir}/raw_data"
    local trimmed_dir="${sample_dir}/trimmed"
    local assembly_dir="${sample_dir}/assembly"
    local trinity_assembly_dir="${assembly_dir}/trinity_assembly"
    local alignment_dir="${sample_dir}/alignment"
    local quantification_dir="${sample_dir}/quantification"
    local coding_regions="${sample_dir}/coding_regions"

    local qc_dir="${sample_dir}/qc"

    local logs_dir="logs"
    local tmp_dir="${sample_dir}/tmp"
    local src="${root_dir}/src"

    # Create directories
    mkdir -p "$sample_dir" "$raw_data_dir" "$trimmed_dir" "$alignment_dir" \
             "$trinity_assembly_dir" "$assembly_dir" "$quantification_dir" \
             "$qc_dir" "$logs_dir" "$tmp_dir" "$coding_regions"

    # Set up file path variables
    # Raw data (symlink original files)
    ln -sf "$(readlink -f "$forward_fastq")" "${raw_data_dir}/${sample_name}_R1.fastq.gz"
    ln -sf "$(readlink -f "$reverse_fastq")" "${raw_data_dir}/${sample_name}_R2.fastq.gz"

    # Define path variables
    declare -gA PATHS  # Global associative array to store all paths
    export PATHS

    # === Base directories for the sample ===
    PATHS["BASE_DIR_INPUT"]="$base_raw_dir"
    PATHS["RAW_R1"]="$forward_fastq"
    PATHS["RAW_R2"]="$reverse_fastq"

    PATHS["SAMPLE_DIR"]="$sample_dir"
    PATHS["RAW_DATA"]="$raw_data_dir"
    PATHS["TRIMMED"]="$trimmed_dir"
    PATHS["ALIGNMENT"]="$alignment_dir"
    PATHS["CODING_REGIONS"]="$coding_regions"

    PATHS["ASSEMBLY_DIR"]="$assembly_dir"
    PATHS["TRINITY_ASSEMBLY_DIR"]="$trinity_assembly_dir"
    PATHS["TRINITY_ASSEMBLY_FASTA"]="$assembly_dir/trinity_assembly.Trinity.fasta"
    PATHS["TRINITY_ASSEMBLY_TRANSMAP"]="$assembly_dir/trinity_assembly.Trinity.fasta.gene_trans_map"
    PATHS["ASSEMBLY_QC_TRINITY_STATS"]="$qc_dir/trinity_assembly_stats.txt"

    PATHS["ASSEMBLY_QC_BUSCO"]="$qc_dir/qc_busco"
    PATHS["ASSEMBLY_QC_BUSCO_PLOT"]="$qc_dir/qc_busco_plot"

    PATHS["ASSEMBLY_QC_TRANSRATE"]="$qc_dir/qc_transrate"
    PATHS["TRANSRATE_ASSEMBLY"]="${PATHS["ASSEMBLY_QC_TRANSRATE"]}/transrate_assembly"
    PATHS["TRANSRATE_READS"]="${PATHS["ASSEMBLY_QC_TRANSRATE"]}/transrate_reads"

    PATHS["TRANSDECODER"]="$coding_regions/transdecoder"


    PATHS["QUANTIFICATION"]="$quantification_dir"

    PATHS["QC"]="$qc_dir"

    PATHS["LOGS"]="$logs_dir"
    PATHS["TMP"]="$tmp_dir"
    PATHS["SRC"]="$src"


    # === File paths for the sample ===

    # Raw input paths
    PATHS["R1"]="${raw_data_dir}/${sample_name}_R1.fastq.gz"
    PATHS["R2"]="${raw_data_dir}/${sample_name}_R2.fastq.gz"

    # Log file path
    PATHS["LOG_MAIN"]="${logs_dir}/${sample_name}.log"
    PATHS["LOG_CMD"]="${logs_dir}/${sample_name}.cmd.log"

    PATHS["TRIMMED_R1"]="${trimmed_dir}/trimmed_forward.fastq.gz"
    PATHS["TRIMMED_R2"]="${trimmed_dir}/trimmed_reverse.fastq.gz"

    # QC READS - TrinityStats
    PATHS["QC_TRINITY_STATS"]="${qc_dir}/trinity_stats"

    # QC READS - FASTQC
    PATHS["QC_FASTQC_RAW"]="${qc_dir}/fastqc_raw"
    PATHS["QC_FASTQC_TRIMMED"]="${qc_dir}/fastqc_trimmed"

    # QC ASSEMBLY - Salmon
    PATHS["QC_SALMON"]="${qc_dir}/salmon"
    PATHS["QC_SALMON_INDEX"]="${PATHS["QC_SALMON"]}/salmon_index"
    PATHS["QC_SALMON_QUANT"]="${PATHS["QC_SALMON"]}/salmon_quant"

    # QC ASSEMBLY - RSEM with Bowtie2
    PATHS["QC_RSEM_BOWTIE2"]="${qc_dir}/rsem_bowtie2"

    # Define Params variables
    declare -gA PARAMS  # Global associative array to store all paths
    export PARAMS

    # Threads equal to number of CPU cores available minus 1
    PARAMS["THREADS"]=$(($(nproc) - 1))

    SAMPLE_DIR="$sample_dir"
    export SAMPLE_DIR



    echo "Created analysis structure for sample: $sample_name"
    echo "Root directory: $sample_dir"
    echo "Forward read: ${PATHS["RAW_R1"]}"
    echo "Reverse read: ${PATHS["RAW_R2"]}"


}

