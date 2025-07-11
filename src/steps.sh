#!/bin/bash

# Declare the global associative array variable for defining the steps that will be executed
# This variable can be used to iterate through the steps in a script or function
# Each step is defined as a boolean value indicating whether the step should be executed

declare -A STEPS=(
    ["raw_qc"]=0
    ["trim"]=0
    ["trim_qc"]=0
    ["assembly"]=1
    ["assembly_qc_stats"]=0
    ["assembly_qc_salmon"]=0
    ["assembly_qc_busco"]=0
    ["assembly_qc_transrate"]=0
    ["coding_region_prediction"]=0
)
export STEPS

declare -a step_order # Declare an array to define the order of steps
export step_order
step_order=("raw_qc" "trim" "trim_qc" "assembly" "assembly_qc_stats" "assembly_qc_salmon")

print_steps() {
    echo ">>> STEPS TO BE EXECUTED:"
    #for step in "${!steps[@]}"; do
    for step in "${step_order[@]}"; do
      # print the step name and its status - print as a table with two columns
        if [[ ${STEPS[$step]} -eq 1 ]]; then
            echo -e "\033[32m$step: ${STEPS[$step]}\033[0m"  # Green for steps to be executed
        else
            echo -e "\033[31m$step: ${STEPS[$step]}\033[0m"  # Red for steps not to be executed
        fi
    done
}

print_steps



