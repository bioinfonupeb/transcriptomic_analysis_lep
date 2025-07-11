#!/bin/bash

ROOT_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export ROOT_PATH

INPUT_FOLDER="${ROOT_PATH}/data/raw"

# For each directory in the data directory, execute the process_data.sh script
for dir in "${INPUT_FOLDER}"/*/; do
    if [ -d "${dir}" ]; then

        # Get the name of sample from the directory name
        SAMPLE_NAME=$(basename "${dir}")
        echo -e "\n\nProcessing sample: ${SAMPLE_NAME}"


        # Create a list variable to store fastq files
        FORWARD_FASTQ=""
        REVERSE_FASTQ=""

        # List all files in the directory
        for file in "${dir}"*; do
          # If the file exists and is a regular file, and has fastq in its name
            if [[ -f "${file}" && "${file}" == *fastq* ]]; then
                if [[ "${file}" == *"_R1_"* ]]; then
                    FORWARD_FASTQ="${file}"
                elif [[ "${file}" == *"_R2_"* ]]; then
                    REVERSE_FASTQ="${file}"
                fi
            fi
        done

        # Check if two fastq files were found
        if [[ -n "${FORWARD_FASTQ}" && -n "${REVERSE_FASTQ}" ]]; then
            # Execute run.sh script with the found fastq
            RUN_CMD="./run.sh ${SAMPLE_NAME} ${FORWARD_FASTQ} ${REVERSE_FASTQ}"
            eval "${RUN_CMD}"

#            exit 1
        else
            echo "Error: Not enough fastq files found in ${dir}. Expected 2 (forward and reverse)."
        fi
        
    else
        echo "Error: ${dir} is not a directory or does not exist."
    fi
done

echo "=== All samples processed ==="

