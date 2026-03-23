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

<div align="center">

![pic1](https://github.com/Kalixie/Gut-Microbiome-Shotgun-Metagenomics-Project-/blob/main/figures/rarecurve.png)

</div>

##### Figure #1: Rarefaction curve for microbial diversity in vegan and omnivore samples. The curves for all six samples reached a plateau indicating that the sequencing depth was sufficient enough to capture the microbial diversity present in each sample. 


Rarefaction curves for all six samples reached a plateau which indicated that sequencing depth was sufficient for this data and therefore suggesting that the majority of microbial diversity present in each sample was captured. This confirms that the data contains enough information for further analysis.

<div align="center">

![pic2](https://github.com/Kalixie/Gut-Microbiome-Shotgun-Metagenomics-Project-/blob/main/figures/RA1Phy.png)

</div>

##### Figure #2:

When datasets were compared at the phylum level for vegan and omnivore groups, the microbial composition observed was similar. All six samples were largely composed of members of the phylum Bacteroidota, with Bacillotia also consistently represented in the relative abundance. The level of Verrucomicrobiota in sample SRR8146974 was notably higher than all other samples, suggesting a potential outlier within the data. Consistent separation was not seen between diets at this taxonomic level. 

<div align="center">

![pic3](https://github.com/Kalixie/Gut-Microbiome-Shotgun-Metagenomics-Project-/blob/main/figures/RA3GenusAv10.png)

</div>

##### Figure #3:

Analysis performed at the Genus level showcased more distinct differences between dietary groups. Omnivorous samples showed consistently high relative abundance of Segatella in all three samples, whereas vegan samples contained a higher abundance of Alistipes in one sample and Bacteroides in two samples. To confirm that these patterns were not biased by selecting the top taxa across all samples, genus level composition was also visualized using the top 10 taxa within each individual sample which produced similar result patterns and supported the differences observed between dietary groups at this level.

<div align="center">

![pic4](https://github.com/Kalixie/Gut-Microbiome-Shotgun-Metagenomics-Project-/blob/main/figures/Alphadiv.png)

</div>

##### Figure #4: 

Alpha diversity metrics showed variability within both dietary groups with no consistent trend indicating higher diversity in the vegan and omnivore groups. Vegan samples exhibited slightly higher diversity values than the small sample size with both Shannon and Simpson indices. 

<div align="center">

![pic5](https://github.com/Kalixie/Gut-Microbiome-Shotgun-Metagenomics-Project-/blob/main/figures/betadiversity.png)

</div>

##### Figure #5:

Beta diversity analyses revealed partial separation between dietary groups. Bray-Curtis PCoA showed some distinction between vegan and omnivorous samples, although one vegan sample appeared as an outlier. Bray-Curtis NMDS distances showed weaker clustering and greater overlap between groups. Jaccard PCoA demonstrated moderate clustering by diet with one vegan sample deviating from the group. 

<div align="center">

![pic6](https://github.com/Kalixie/Gut-Microbiome-Shotgun-Metagenomics-Project-/blob/main/figures/ancombctop.png)

</div>

##### Figure #6:

PERMANOVA analysis using Bray-Curtis distances showcased that diet explained approximately 35.8% of the variation in microbial composition, although this effect was not statistically significant. Differential abundance testing using ANCOM-BC identified no genera that were significantly different between vegan and omnivorous groups after multiple testing correction. 

## Discussion

The results of this metagenomic analysis demonstrate that higher-level taxonomic structure is relatively conserved regardless of dietary pattern. Both omnivore and vegan samples had similar abundance results, with a high abundance of Bacteroidota over 50% in all six samples. Bacillota, also known as Firmicutes, were also represented at smaller abundance rates throughout all 6 samples. Bacteroidota and Firmicutes are known to make up the majority of the human gut microbiome, with previous studies noting the variability of Bacteroidota across diet samples (Arumugam et al., 2011). Both are responsible for around 90% of gut phyla, with other groups accounting for the remaining 10% (Johnson et al., 2017). Bacteroidetes are responsible for the fermentation of polysaccharides to produce short-chain fatty acids for host energy (Johnson et al., 2017). 

The genus level results seen during this analysis demonstrate patterns that were not fully consistent with what is typically seen in omnivore and vegan metagenomic gut studies. A high abundance of Bacteroides as seen in vegan samples SRR814677 and SRR8146978, has been found to be more abundant in either vegan and omnivorous diets according to previous literature comparing the results of diet habits across several studies (Al-Refai et al,. 2025). 

The abundance of genus Segatella in omnivorous samples is potentially influenced by local diet as it has been noted in previous studies that Segatella gut abundance is influenced by a wide range of dietary factors, including a diet lacking in variety of nutrients (Muñoz-Yáñez et al., 2025). Studies have also noted that Segatella copri is associated with high fiber and plant polysaccharides, the same trend was not seen within the vegan diet in this study despite the presence of Segatella copri in all six samples (Panwar, 2025). A larger sample size for each diet group could aid in clarifying whether this data reflects true sample variation or is the result of bias.

The results seen may possibly be explained by regional dietary variation as the samples originate from Italy, where omnivorous diets can still include substantial amounts of plant based foods. Mediterranean diets are primarily composed of high levels of plant content such as vegetables, nuts, and fruits with low consumption of red and processed meat (Daley et al., 2026). The high abundance of Akkermansia in the vegan sample SRR8146974 may reflect increased presence of Verrucomicrobiota seen in the phyla analysis. Akkermansia muciniphila, a species seen within the data, is associated with dietary patterns high in fermented foods and plant based compounds and likely reflects a specific diet pattern of the sampled individual (Kumar et al., 2025).

Alpha diversity analysis revealed no consistent differences between dietary groups in both Shannon and Simpson indices, although higher diversity was observed in vegan samples. Omnivorous samples demonstrate higher variability with an outlier in both indices that overlapped with the vegan group. This potentially reflects individual specific microbiota patterns and the small sample size used for analysis. Beta diversity analysis showcased slight clustering by diet in both Bray-Curtis and Jaccard PCoA plots, however, due to the small sample size of the study and the clear outliers in the diagram it does not clearly suggest that dietary patterns may potentially influence overall microbiota. The results of the PERMANOVA attributed 35.8% of variation to diet but was not statistically significant, further supporting this interpretation. The differential abundance analysis using ANCOMBC did not identify any significantly different taxa. Although some genera had low unadjusted p-values, these did not remain significant following correction, likely due to the small study sample size. 

Overall, while some microbiota differences were observed visually through abundance diagrams, no statistically significant differences were detected. This is potentially due to the small sample sizes used for this study (3 vegan, 3 omnivores) leading to a lack of significant differences between each diet. Future studies should aim to include larger sets of sample data for more accurate and conclusive results.


## References 

Al-Refai, W., Keenan, S., Camera, D. M., & Cooke, M. B. (2025). The Influence of Vegan, Vegetarian, and Omnivorous Diets on Protein Metabolism: A Role for the Gut-Muscle Axis?. Nutrients, 17(7), 1142. https://doi.org/10.3390/nu17071142

Arumugam, M., Raes, J., Pelletier, E., Le Paslier, D., Yamada, T., Mende, D. R., Fernandes, G. R., Tap, J., Bruls, T., Batto, J. M., Bertalan, M., Borruel, N., Casellas, F., Fernandez, L., Gautier, L., Hansen, T., Hattori, M., Hayashi, T., Kleerebezem, M., Kurokawa, K., … Bork, P. (2011). Enterotypes of the human gut microbiome. Nature, 473(7346), 174–180. https://doi.org/10.1038/nature09944

Daley SF, Hinson MR. Mediterranean Diet. [Updated 2026 Jan 10]. In: StatPearls [Internet]. Treasure Island (FL): StatPearls Publishing; 2026 Jan-. Available from: https://www.ncbi.nlm.nih.gov/books/NBK557733/

Fackelmann, G., Manghi, P., Carlino, N., Heidrich, V., Piccinno, G., Ricci, L., Piperni, E., Arrè, A., Bakker, E., Creedon, A. C., Francis, L., Capdevila Pujol, J., Davies, R., Wolf, J., Bermingham, K. M., Berry, S. E., Spector, T. D., Asnicar, F., & Segata, N. (2025). Gut microbiome signatures of vegan, vegetarian and omnivore diets and associated health outcomes across 21,561 individuals. Nature microbiology, 10(1), 41–52. https://doi.org/10.1038/s41564-024-01870-z

Johnson, E. L., Heaver, S. L., Walters, W. A., & Ley, R. E. (2017). Microbiome and metabolic disease: revisiting the bacterial phylum Bacteroidetes. Journal of molecular medicine (Berlin, Germany), 95(1), 1–8. https://doi.org/10.1007/s00109-016-1492-2

Kumar, S., Mukherjee, R., Gaur, P., Leal, É., Lyu, X., Ahmad, S., Puri, P., Chang, C. M., Raj, V. S., & Pandey, R. P. (2025). Unveiling roles of beneficial gut bacteria and optimal diets for health. Frontiers in microbiology, 16, 1527755. https://doi.org/10.3389/fmicb.2025.1527755

Lin, H., & Peddada, S. D. (2023). Multi-group Analysis of Compositions of Microbiomes with Covariate Adjustments and Repeated Measures. Research square, rs.3.rs-2778207. https://doi.org/10.21203/rs.3.rs-2778207/v1

Lu, J., Breitwieser, F. P., Thielen, P., & Salzberg, S. L. (2017). Bracken: estimating species abundance in metagenomics data. PeerJ. Computer science, 3, e104. https://doi.org/10.7717/peerj-cs.104

McMurdie, P. J., & Holmes, S. (2013). phyloseq: an R package for reproducible interactive analysis and graphics of microbiome census data. PloS one, 8(4), e61217. https://doi.org/10.1371/journal.pone.0061217

Muñoz-Yáñez, C., Méndez-Hernández, A., González-Galarza, F. F., Prieto-Hinojosa, A. I., & Guangorena-Gómez, J. O. (2025). Diet Quality Modulates Gut Microbiota Structure in Blastocystis-Colonised Individuals from Two Distinct Cohorts with Contrasting Sociodemographic Profiles. Microorganisms, 13(8), 1949. https://doi.org/10.3390/microorganisms13081949

Oksanen, J., Simpson, G. L., Blanchet, F. G., Kindt, R., Legendre, P., Minchin, P. R., ... & Wagner, H. (2025). vegan: Community Ecology Package (Version 2.8-0) [Software]. https://cran.r-project.org/web/packages/vegan/index.html

Panwar, D., Briggs, J., Fraser, A. S. C., Stewart, W. A., & Brumer, H. (2025). Transcriptional delineation of polysaccharide utilization loci in the human gut commensal Segatella copri DSM18205 and co-culture with exemplar Bacteroides species on dietary plant glycans. Applied and environmental microbiology, 91(1), e0175924. https://doi.org/10.1128/aem.01759-24

Xu, R., Rajeev, S., & Salvador, L. C. M. (2023). The selection of software and database for metagenomics sequence analysis impacts the outcome of microbial profiling and pathogen detection. PloS one, 18(4), e0284031. https://doi.org/10.1371/journal.pone.0284031

Zhang P. (2022). Influence of Foods and Nutrition on the Gut Microbiome and Implications for Intestinal Health. International journal of molecular sciences, 23(17), 9588. https://doi.org/10.3390/ijms23179588



 
