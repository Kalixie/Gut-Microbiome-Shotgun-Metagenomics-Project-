#!/bin/bash

# Create conda enviroment for metagenomic tools

conda create -n metagenomics kraken2 bracken fastqc fastp sra-tools -y

conda activate metagenomics

# Retrieve file list

nano srrids.txt

SRR8146978
SRR8146977
SRR8146974
SRR8146971
SRR8146969
SRR8146936

# Use SRA toolkit to retrieve files

#!/bin/bash
#SBATCH --job-name=sradownload
#SBATCH --output=download_%j.log
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=32
#SBATCH --mem=50G
#SBATCH --time=12:00:00

mkdir -p sra_files fastq_files

cd sra_files
for srr in $(cat ../srrids.txt)
do
    prefetch $srr
done

cd ../fastq_files
for srr in $(cat ../srrids.txt)
do
    fasterq-dump ../sra_files/$srr/$srr.sra --split-files --threads 32
done

# Run Fastqc to check quality

mkdir qcheck1

fastqc *.fastq -o qcheck1

# Check quality, looks good - no trim needed

# Run Kracken2

#!/bin/bash
#SBATCH --job-name=krakenrun
#SBATCH --output=kraken_%j.log
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=64
#SBATCH --mem=75G
#SBATCH --time=12:00:00

# Kraken2 DB path

KRAKEN2_DB=/cvmfs/bio.data.computecanada.ca/content/databases/Core/kraken2_dbs/2026_02_15/k2_standard_16_GB_20251015

mkdir -p kraken_output kraken_reports

for sample in SRR8146978 SRR8146977 SRR8146974 SRR8146971 SRR8146936 SRR8146969
do
  kraken2 \
    --db $KRAKEN2_DB \
    --confidence 0.2 \
    --threads 64 \
    --paired \
    --use-names \
    ${sample}_1.fastq ${sample}_2.fastq \
    --output kraken_output/${sample}.kraken \
    --report kraken_reports/${sample}.report
done

# Run Bracken for species abundance

#!/bin/bash
#SBATCH --job-name=brackenrun
#SBATCH --output=bracken_%j.log
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=20G
#SBATCH --time=01:00:00

mkdir -p bracken_results

KRAKEN2_DB=/cvmfs/bio.data.computecanada.ca/content/databases/Core/kraken2_dbs/2026_02_15/k2_standard_16_GB_20251015

for sample in SRR8146978 SRR8146977 SRR8146974 SRR8146971 SRR8146936 SRR8146969
do
  bracken \
  -d $KRAKEN2_DB \
  -i kraken_reports/${sample}.report \
  -o bracken_results/${sample}.bracken \
  -r 150 \
  -l S
done

# Convert results to BIOM

conda create -n krakenbiom python=3.11
conda activate krakenbiom
conda install kraken-biom

kraken-biom kraken_reports/*_bracken_species.report -o table.biom

# R Import for further Analysis

