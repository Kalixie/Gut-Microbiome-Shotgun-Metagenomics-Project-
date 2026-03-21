# Gut-Microbiome-Shotgun-Metagenomics-Project-

## Introduction

Through the use of publicly available human gut microbiome sequencing data, this study aimed to investigate differences in gut microbial composition between individuals with vegan and omnivorous diets. Vegan diets are typically more high in fiber, while omnivore diets are higher in protein and fats. These differences throughout long-term dietary patterns, such as veganism or an omnivore diet can alter the diversity and function of the gut microbiome (Zhang, 2022).  Specific microbes have been shown to correlate with human health outcomes and further research into the differences between specific diets can benefit nutritional studies (Fackelmann et al., 2025). 

The data used in this study was collected from the National Center for Biotechnology Information. All collected samples were from subjects based in Turin, Italy for consistency, with human reads already removed from microbiome data. Three omnivore samples and three vegan samples were used for analysis.

The data collected was used to perform a shotgun metagenomic analysis. Taxonomic classification was performed using Kraken2 with Bracken used to further reestimate abundance levels allowing for corrections. Kraken was chosen due to its wide use in taxonomic classification studies, as well as the availability of datasets for analysis. Previous studies have also found Kracken2 and Bracken to be efficient for microbial analysis in comparison to alternatives such as Diamond and Megan (Xu et al., 2023)

Downstream analysis was conducted in R using the phyloseq package which allowed abundance data to be illustrated along with metadata through the use of vegan and ggplot2 (McMurdie and Holmes, 2013). Alpha and beta diversity metrics were used to assess sample variation, while differential abundance testing was performed using ANCOMBC2, a method that accounts for compositionality and taxon bias in microbiome data (Lin and Peddada, 2023). 

## Methods

### Data acquisition and preprocessing

Shotgun metagenomic sequencing data for six human gut microbiome samples were obtained from publicly available Sequence Read Archive (SRA) datasets through the usage of sra-tools. The dataset consisted of three vegan (SRR8146978, SRR8146977, SRR8146974) and three omnivorous samples  (SRR8146971, SRR8146969, SRR8146936). Data was quality checked through the usage of fastQC to evaluate read quality. Original reads were used for downstream analysis as quality was high.

### Taxonomic Classification

Kraken2 was used to classify sequencing reads against the standard Kraken2 database,16 GB version February 2026 release stored on the Canada Compute Nibi cluster. Each sample was processed in paired end mode with a confidence threshold of 0.2, generating both Kraken output files and classification reports. 

### Abundance Estimation

To improve abundance estimation, Bracken was applied to Kraken2 output to re-estimate species level abundances using Bayesian models of k-mer distribution (Lu et al., 2017). Parameters were set to read length 150 bp and taxonomic level S for species. Bracken reports generated were combined into a single BIOM format file using kraken-biom (v. 1.2.0). This BIOM file was then imported into R for further analysis.

### Import into R

The BIOM file was imported into R using the biomformat (v. 1.36.0) package and converted into a phyloseq object using phyloseq (v. 1.520) (McMurdie and Holmes, 2013). Sample metadata such as diet information was manually added to the phyloseq object. Low abundance taxa were filtered to reduce noise and improve downstream statistical analyses and data was transformed into relative abundances for normalization in order to make proper comparisons. Rarefaction curves were generated using the rarecurve function from the vegan package to assess sampling depth.

### Diversity analysis

Alpha diversity metrics, including Shannon and Simpson indices, were calculated using the plot_richness function from phyloseq to compare sample diversity within dietary groups. Beta diversity was assessed using Bray-Curtis dissimilarity and Jaccard distance metrics, calculated using the vegan package (Oksanen et al., 2026). Principal Coordinates Analysis and Non-metric Multidimensional Scaling were used to depict differences in microbial community composition between samples.

### Differential abundance testing

Differential abundance analysis was conducted using ANCOMBC2 (v. 2.13.1), which accounts for compositional bias and unequal sampling fractions in microbiome data (Lin and Peddada, 2023). Genus abundances were tested for differences between vegan and omnivore groups using a fixed effects model with diet as the main variable. Taxa were considered significantly differentially abundant if they met a threshold of adjusted p value < 0.05.

## Results:

Rarefaction curves for all six samples reached a plateau which indicated that sequencing depth was sufficient for this data and therefore suggesting that the majority of microbial diversity present in each sample was captured. This confirms that the data contains enough information for further analysis.

When datasets were compared at the phylum level for vegan and omnivore groups the microbial composition observed was similar. All six samples were largely composed of members of the phylum Bacteroidota, with Bacillotia also consistently represented in the relative abundance. The level of Verrucomicrobiota in sample SRR8146974 was notably higher than all other samples, suggesting a potential outlier within the data. Consistent separation was not seen between diets at this taxonomic level. 

Analysis performed at the Genus level showcased more distinct differences between dietary groups. Omnivorous samples showed consistently high relative abundance of Segatella in all three samples, whereas vegan samples contained a higher abundance of Alistipes in one sample and Bacteroides in two samples. To confirm that these patterns were not biased by selecting the top taxa across all samples, genus level composition was also visualized using the top 10 taxa within each individual sample which produced similar result patterns and supported the differences observed between dietary groups at this level.

Alpha diversity metrics showed variability within both dietary groups with no consistent trend indicating higher diversity in the vegan and omnivore groups. Vegan samples exhibited slightly higher diversity values than the small sample size with both Shannon and Simpson indices. Beta diversity analyses revealed partial separation between dietary groups. Bray-Curtis PCoA showed some distinction between vegan and omnivorous samples, although one vegan sample appeared as an outlier. Bray-Curtis NMDS distances showed weaker clustering and greater overlap between groups. Jaccard PCoA demonstrated moderate clustering by diet with one vegan sample deviating from the group.


 
