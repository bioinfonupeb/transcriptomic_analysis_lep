# Reads QC - FASTQC

docker run --rm -v /mnt/nupeb/lep/transcriptomic_analysis_lep/processed/Sample_Lasiodora_15_2:/data -v /mnt/nupeb/lep/transcriptomic_analysis_lep/data/raw/Sample_Lasiodora_15_2:/raw -v /mnt/nupeb/lep/transcriptomic_analysis_lep/src:/src -u 1000 -w /data biocontainers/fastqc:v0.11.9_cv8 fastqc -o /mnt/nupeb/lep/transcriptomic_analysis_lep/davila_teste/fastqc_raw /raw/Lasiodora_15_2_S4_L002_R1_001.fastq-004.gz  /raw/Lasiodora_15_2_S4_L002_R2_001.fastq-005.gz


