# Transcriptomic analysis workflow

## About this project

This workflow is designed to execute a series of steps to process RNA-seq data, including quality control and analysis, 
transcriptome assembly, and differential expression analysis. It is built using Lightflow, a Python-based workflow 
management system that allows for easy execution and management of complex workflows.

All workflow steps are executed using bioinformatics tools in a containerized environment, ensuring reproducibility 
and consistency across different computing environments. It includes the following tools:
- FastQC: A quality control tool for high-throughput sequencing data.
- Trimmomatic: A tool for trimming Illumina sequencing data.
- Bowtie2: A fast and sensitive read aligner for RNA-seq data.
- Salmon: A tool for quantifying transcript abundance from RNA-seq data.
- DESeq2: A tool for differential expression analysis of RNA-seq data.
- BLAST: A tool for comparing nucleotide or protein sequences to sequence databases.

## General Instructions
- Make sure you are using Python 3.8 or later.
- Install Lightflow and its dependencies. You can find the installation instructions in the [Lightflow documentation]
  (https://lightflow.readthedocs.io/en/latest/installation.html).
