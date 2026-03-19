# Gut-Microbiome-Shotgun-Metagenomics-Project-

## Introduction

Through the use of publicly available human gut microbiome sequencing data, this study aimed to investigate differences in gut microbial composition between individuals with vegan and omnivorous diets. Vegan diets are typically more high in fiber, while omnivore diets are higher in protein and fats. These differences throughout long-term dietary patterns, such as veganism or an omnivore diet can alter the diversity and function of the gut microbiome (Zhang, 2022).  Specific microbes have been shown to correlate with human health outcomes and further research into the differences between specific diets can benefit nutritional studies (Fackelmann et al., 2025). 

The data used in this study was collected from the National Center for Biotechnology Information. All collected samples were from subjects based in Turin, Italy for consistency, with human reads already removed from microbiome data. Three omnivore samples and three vegan samples were used for analysis.

The data collected was used to perform a shotgun metagenomic analysis. Taxonomic classification was performed using Kraken2 with Bracken used to further reestimate abundance levels allowing for corrections. Kraken was chosen due to its wide use in taxonomic classification studies, as well as the availability of datasets for analysis. Previous studies have also found Kracken2 and Bracken to be efficient for microbial analysis in comparison to alternatives such as Diamond and Megan (Xu et al., 2023)

Downstream analysis was conducted in R using the phyloseq package which allowed abundance data to be illustrated along with metadata through the use of vegan and ggplot2 (McMurdie and Holmes, 2013). Alpha and beta diversity metrics were used to assess sample variation, while differential abundance testing was performed using ANCOMBC2, a method that accounts for compositionality and taxon bias in microbiome data (Lin and Peddada, 2023). 

## Methods

###Data acquisition and preprocessing

Shotgun metagenomic sequencing data for six human gut microbiome samples were obtained from publicly available Sequence Read Archive (SRA) datasets through the usage of sra-tools. The dataset consisted of three vegan (SRR8146978, SRR8146977, SRR8146974) and three omnivorous samples  (SRR8146971, SRR8146969, SRR8146936). Data was quality checked through the usage of fastQC to evaluate read quality. Original reads were used for downstream analysis as quality was high.

###Taxonomic Classification

Kraken2 was used to classify sequencing reads against the standard Kraken2 database,16 GB version February 2026 release stored on the Canada Compute Nibi cluster. Each sample was processed in paired end mode with a confidence threshold of 0.2, generating both Kraken output files and classification reports. 

###Abundance Estimation

To improve abundance estimation, Bracken was applied to Kraken2 output to re-estimate species level abundances using Bayesian models of k-mer distribution (Lu et al., 2017). Parameters were set to read length 150 bp and taxonomic level S for species. Bracken reports generated were combined into a single BIOM format file using kraken-biom (v. 1.2.0). This BIOM file was then imported into R for further analysis.
