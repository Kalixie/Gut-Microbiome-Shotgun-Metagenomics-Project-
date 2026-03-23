# Load Packages ----

library(phyloseq)
library(biomformat)
library(vegan)
library(ggplot2)
library(ANCOMBC)
library(dplyr)
library(gridExtra)

# remotes::install_github("FrederickHuangLin/ANCOMBC")

# Import and Format Data ----

# Read the BIOM file

biom_data <- read_biom("table.biom")
physeq <- import_biom(biom_data)

physeq <- filter_taxa(physeq, function(x) sum(x) > 10, TRUE)

# Create metadata (sample information)

metadf <- data.frame(
  SampleID = c(
    "SRR8146978", "SRR8146977", "SRR8146974",
    "SRR8146971", "SRR8146969", "SRR8146936"
  ),
  Diet = c(
    "Vegan", "Vegan", "Vegan",
    "Omnivore", "Omnivore", "Omnivore"
  )
)

rownames(metadf) <- metadf$SampleID

sample_names(physeq)
rownames(metadf)

# Remove the '_bracken_species' suffix

sample_names(physeq) <- sub("_bracken_species$", "", sample_names(physeq))

sample_names(physeq)
rownames(metadf)

# Metadata and physeq match

sample_data(physeq) <- sample_data(metadf)

# Check

data.frame(
  Sample = sample_names(physeq),
  Diet = sample_data(physeq)$Diet
)

physeq

# Rarefaction ----

otu_table_df <- as.data.frame(t(otu_table(physeq)))

diet <- sample_data(physeq)$Diet

cols <- ifelse(diet == "Vegan", "forestgreen", "darkorange")

rare_curve <- rarecurve(otu_table_df, step = 1000, label = TRUE, col = cols)

legend("bottomright",
  legend = c("Vegan", "Omnivore"),
  col = c("forestgreen", "darkorange"),
  lty = 1
)

# Relative Abundance Phylum ----

# Correct names

colnames(tax_table(physeq)) <- c("Kingdom", "Phylum", "Class", "Order", "Family", "Genus", "Species")

tax_table(physeq) <- tax_table(physeq) %>%
  apply(2, function(x) gsub("^[a-z]__", "", x))

taxdf <- as.data.frame(tax_table(physeq))
head(taxdf)

# Relative abundance for phylum

physeq_rel <- transform_sample_counts(physeq, function(x) x / sum(x))

physeq_phy <- tax_glom(physeq_rel, taxrank = "Phylum")

df <- psmelt(physeq_phy)

ggplot(df, aes(x = Sample, y = Abundance, fill = Phylum)) +
  geom_bar(stat = "identity", position = "stack") +
  labs(y = "Relative Abundance", x = "Sample") +
  facet_wrap(~Diet, scales = "free_x")

# Average barplot

ggplot(df, aes(x = Diet, y = Abundance, fill = Phylum)) +
  stat_summary(fun = "mean", geom = "bar", position = "stack")

# Relative Abundance Genus ----

physeq_genus <- tax_glom(physeq_rel, taxrank = "Genus")

# keep top 10 but lump others

top10 <- names(sort(taxa_sums(physeq_genus), decreasing = TRUE))[1:10]

physeq_genus <- transform_sample_counts(physeq_genus, function(x) x / sum(x))

df <- psmelt(physeq_genus)

df$Genus <- ifelse(df$OTU %in% top10, as.character(df$Genus), "Other")

ggplot(df, aes(x = Sample, y = Abundance, fill = Genus)) +
  geom_bar(stat = "identity") +
  facet_wrap(~Diet, scales = "free_x")


# Agglomerate at genus level

physeq_genus <- tax_glom(physeq_rel, taxrank = "Genus")

# Melt to dataframe

df <- psmelt(physeq_genus)

# Clean genus names

df$Genus <- as.character(df$Genus)
df$Genus[is.na(df$Genus)] <- "Unclassified"

# Get top 10 taxa per sample

df_top <- df %>%
  group_by(Sample) %>%
  arrange(desc(Abundance)) %>%
  mutate(rank = row_number()) %>%
  mutate(Genus_top = ifelse(rank <= 10, Genus, "Other")) %>%
  group_by(Sample, Genus_top, Diet) %>%
  summarise(Abundance = sum(Abundance), .groups = "drop")

# Plot

ggplot(df_top, aes(x = Sample, y = Abundance, fill = Genus_top)) +
  geom_bar(stat = "identity") +
  facet_wrap(~Diet, scales = "free_x") +
  labs(y = "Relative Abundance", x = "Sample", fill = "Genus") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# Alpha Diversity ----

plot_richness(physeq, x = "Diet", measures = c("Shannon", "Simpson"))

# Beta Diversity ----

# Bray-Curtis

ord.pcoa.bray <- ordinate(physeq, method = "PCoA", distance = "bray")

p1 <- plot_ordination(physeq, ord.pcoa.bray, color = "Diet") +
  scale_color_manual(values = c("Omnivore" = "darkorange", "Vegan" = "forestgreen")) +
  geom_point(size = 4) +
  labs(x = "PC1: 40.1%", y = "PC2: 27.8%", title = "Bray-Curtis PCoA")

# Jaccard

ord.pcoa.jaccard <- ordinate(physeq, method = "PCoA", distance = "jaccard")

p2 <- plot_ordination(physeq, ord.pcoa.jaccard, color = "Diet") +
  scale_color_manual(values = c("Omnivore" = "darkorange", "Vegan" = "forestgreen")) +
  geom_point(size = 4) +
  labs(x = "PC1: 33.7%", y = "PC2: 24.8%", title = "Jaccard PCoA")

grid.arrange(p1, p2, nrow = 1)

# PERMANOVA test ----

metadata <- as(sample_data(physeq), "data.frame")
adonis2(phyloseq::distance(physeq, method = "bray") ~ Diet, data = metadata)

# Differential abundance with ANCOMBC ----

ancombc.out <- ancombc2(
  data = physeq,
  tax_level = "Genus",
  fix_formula = "Diet",
  group = "Diet",
  p_adj_method = "holm"
)

# Significant taxa

ancombc.sig <- subset(ancombc.out$res, q_DietVegan < 0.05)
ancombc.sig

# nothing...

# Plot all log-fold changes

ggplot(ancombc.out$res, aes(x = lfc_DietVegan, y = reorder(taxon, lfc_DietVegan))) +
  geom_point(aes(color = q_DietVegan < 0.05), size = 3) +
  geom_errorbar(aes(
    xmin = lfc_DietVegan - se_DietVegan,
    xmax = lfc_DietVegan + se_DietVegan
  )) +
  geom_vline(xintercept = 0, color = "red") +
  scale_color_manual(values = c("FALSE" = "grey", "TRUE" = "blue")) +
  labs(x = "Log Fold Change (Vegan vs Omnivore)", y = "Genus", color = "Significant (q<0.05)")

# Top effect sizes

res <- ancombc.out$res

top_taxa <- res %>%
  arrange(desc(abs(lfc_DietVegan))) %>%
  slice(1:15)

ggplot(top_taxa, aes(x = lfc_DietVegan, y = reorder(taxon, lfc_DietVegan))) +
  geom_point(aes(color = q_DietVegan < 0.05), size = 3) +
  geom_errorbar(aes(xmin = lfc_DietVegan - se_DietVegan, xmax = lfc_DietVegan + se_DietVegan)) +
  geom_vline(xintercept = 0, color = "red") +
  scale_color_manual(values = c("FALSE" = "grey", "TRUE" = "blue")) +
  labs(x = "Log Fold Change (Vegan vs Omnivore)", y = "Genus", color = "Significant (q<0.05)") +
  theme_bw()
