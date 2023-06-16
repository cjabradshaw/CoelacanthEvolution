##############################################################################
#### Final analyses Coelacanth disparity ####
#### December 2022 ##########################
##############################################################################

library(ggplot2)
library(plyr)
library(scales)
library(grid)
library(reshape2)
library(stats)
library(dplyr)
library(stats)
library(ggrepel)
library(readxl)

###############################################################################
##### Disparity : Discrete characters #########
###############################################################################

# Libraries

library(vegan)
library(Momocs)
library(dispRity)
library(cluster)

# Import Data ------------------------------------------

# Nexus file : Taxa x Characters

Revised_matrix <- read.nexus.data("Matrix_corrected.nex")
Revised_matrix


df_revised = data.frame(Revised_matrix)
Revised_df2 <- data.frame(t(df_revised))
Revised_df2

Revised_df2 <- Revised_df2 %>%
  mutate_if(is.character, as.factor) 

# Table Taxa x period

Period_habitats <- read_excel(file.choose(), 1) #Open age-habitat.xlsx
Period_habitats

Period_habitats <- Period_habitats %>%
  mutate_if(is.character, as.factor)

# Morphospaces -------------------------------------

# Gower's Distance calculation

gw_distance_revised <- daisy(Revised_df2, metric = "gower")#calcul of dissimilarites

# Principal coordinates analysis

Pcoa_discret_revised <- pcoa(gw_distance_revised)

Pcoa_discret_revised$values
Pcoa_discret_revised$vectors

biplot(Pcoa_discret_revised, Y=NULL, plot.axes = c(1,2), dir.axis1=1,
       dir.axis2=1, rn=NULL, main=NULL) # axis 1 vs 2

biplot(Pcoa_discret_revised, Y=NULL, plot.axes = c(2,3), dir.axis1=2, dir.axis2=3, rn = NULL, main = NULL) #axis 2 vs 3 

# Morphospace
gg_revised <- Pcoa_discret_revised$vectors[,1:3] # 3 first axes of PCO
gg_revised <- data.frame(gg_revised)
gg_revised$Periods <- Period_habitats$`Period (R)`

cols <- c("Devonian" = "#CB8C37", "Carboniferous" = "#67A599", "Permian" = "#F04028", "Triassic" = "#812B92", "Jurassic" = "#34B2C9", "Cretaceous" = "#7FC64E", "Extant" = "#F9F97F") # color periods following international chronostratigraphic chart

ggplot(gg_revised,aes(x = Axis.1, y = Axis.2, label = rownames (gg_revised), fontface = "italic")) + labs(fill="Periods") +
  
  geom_point(aes(fill = Period_habitats$`Period (R)`), color = "black", size = 6, shape = 21, stroke = 0.10) +
  scale_fill_manual(values = cols) +
  
  lims(x = c(-0.5,0.5), y = c(-0.3,0.3)) +
  
  theme_bw() +
  theme(axis.text.x = element_text(size = 25, color="black", margin = margin(t = 5, r = 0, b = 0, l = 0)),
        axis.text.y = element_text(size = 25, color="black", margin = margin(t = 0, r = 5, b = 0, l = 0)), 
        axis.title.x = element_text(size = 29, margin = margin(t = 15, r = 0, b = 0, l = 0)), 
        axis.title.y = element_text(size = 29, margin = margin(t = 0, r = 15, b = 0, l = 0))) +
  
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(), legend.position = "none") +
  
  geom_text(hjust=0, vjust=0,color="black", size = 3) +
  
  labs(x="PCO 1 = 42.01 %", y = "PCO 2 = 11.30 %") #PCO1 vs PCO2


###############################################################################
##### Disparity : Geometric morphometrics #########
###############################################################################

# Libraries
library(geomorph)

####################### Postcranial disparity #############################
# Import Data ------------------------------------------
# TPS file : 14 2D-landmarks and 35 species

coelacanth_PC <- readland.tps("Postcranial.TPS",specID="imageID",negNA = TRUE,warnmsg = TRUE)
nom <- dimnames(coelacanth_PC)[[3]]
dim(coelacanth_PC)

# Table Taxa x period
Period_habitats_PC <- read_excel(file.choose(), 1) #Open age-habitats-GM-PC.xlsx
Period_habitats_PC

Period_habitats_PC <- Period_habitats_PC %>%
  mutate_if(is.character, as.factor)

# Principal component analysis -------------------------------------------
# Procrustes superimposition

data.super_PC <- gpagen(coelacanth_PC, ProcD = FALSE)
attributes(data.super_PC)
plot(data.super_PC) 

# PCA 
pca_PC <- gm.prcomp(data.super_PC$coords)
pca_PC

plot_PC <- plot(pca_PC, axis1 = 1, axis2 = 2)
text(pca_PC[["x"]][,1], pca_PC[["x"]][,2], labels = nom) #PCA 1 vs 2

plot_PC2 <- plot(pca_PC, axis1=2, axis2=3)
text(pca_PC[["x"]][,2], pca_PC[["x"]][,3], labels = nom) #PCA 1 vs 3

picknplot.shape(plot_PC) #generate deformation grid for a chosen specimen

PC.scores_PC<- pca_PC$x #save PC scores

as.data.frame(PC.scores_PC)

# Morphospace -------------------------------------
ggplot(as.data.frame(PC.scores_PC), aes(x=PC.scores_PC[,1], y=PC.scores_PC[,2], label = nom, fontface = "italic")) +
  labs(fill="Periods") +
  coord_fixed(ratio = 1) +
  
  geom_point(aes(fill = Period_habitats_PC$`Period (Stage)`), color = "black", size = 6, shape = 21, stroke = 0.10)  +
  scale_fill_manual(values = cols)+
  
  lims(x=c(-0.5,0.5), y = c(-0.3,0.3)) +
  
  theme_bw() +
  theme(axis.text.x = element_text(size = 25, color="black", margin = margin(t = 5, r = 0, b = 0, l = 0)),
        axis.text.y = element_text(size = 25, color="black", margin = margin(t = 0, r = 5, b = 0, l = 0)), 
        axis.title.x = element_text(size = 29, margin = margin(t = 15, r = 0, b = 0, l = 0)), 
        axis.title.y = element_text(size = 29, margin = margin(t = 0, r = 15, b = 0, l = 0))) +
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(), legend.position = "none") +
  geom_text(hjust=0, vjust=0,color="black", size = 3) +
  labs(x = "PC1 = 35.33 %", y = "PC2 = 21.35 %" ) #PC 1 vs 2

# Morphological disparity: Procrustes variances ---------------------------------------------
# Import data
gdf_PC <- geomorph.data.frame(data.super_PC, species = Period_habitats_PC$Taxon, Time = Period_habitats_PC$`Period (Stage)`)
gdf_PC

# Procrustes variances
SOV_mean <- morphol.disparity(coords ~ 1, groups= ~ Time, partial = TRUE, 
                              data = gdf_PC, iter = 999, print.progress = FALSE) #calculate disparity of the time bins and comparing it to the grand mean

summary(SOV_mean)

SOV <- morphol.disparity(coords~Time,groups=~Time, data = gdf_PC, iter = 999) #If you want to calculate the disparity within each group, and compare that to the disparity within other groups, this is the syntax. This tells me which time bin is most/least disparate
summary(SOV)

# Graphical representation 
SoV_PC <- c("0.014607552", "0.032271062", "0.003859100", "0.021567889", "0.012613369", "0.006396594", "0.002598122")
periods <- c("Devonian", "Carboniferous", "Permian", "Triassic", "Jurassic", "Cretaceous", "Extant")
SoV_PC <- as.numeric(as.character(SoV_PC))
periods <- as.factor(as.character(periods))

DF_SoV <- data.frame(Periods = periods, SoV = SoV_PC)
DF_SoV

level_order <- factor(DF_SoV$Periods, level = c("Devonian", "Carboniferous", "Permian", "Triassic", "Jurassic", "Cretaceous", "Extant"))

ggplot(DF_SoV, aes(x=level_order, y=SoV, group = 1)) +
  geom_line(color = "black") +
  geom_point()+
  scale_y_continuous(limits = c(0,0.04))+
  theme_bw()+
  theme(panel.border = element_blank(), panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(), axis.line = element_line(colour = "black"))


##################### Cheek disparity ######################################
# TPS file: 17 2D-mandmarks and 35 species
Skull <- readland.tps("Skull.TPS",specID="imageID",negNA = TRUE,warnmsg = TRUE)

nom_SK <- dimnames(Skull)[[3]]

dim(Skull)

# Importer la matrice Taxons x Periode et habitats #
Period_habitats_SK <- read_excel(file.choose(), 1) #open age-habitat-skull.xlsx
Period_habitats_SK

Period_habitats_SK <- Period_habitats_SK %>%
  mutate_if(is.character, as.factor)

# Principal component analysis -------------------------------------------
# Procrustes superimposition
data.super_SK <- gpagen(Skull, ProcD = FALSE)
attributes(data.super_SK)

plot(data.super_SK) 

# PCA
pca_SK <- gm.prcomp(data.super_SK$coords)
pca_SK

plot_SK <- plot(pca_SK, axis1 = 1, axis2 = 2)
text(pca_SK[["x"]][,1], pca_SK[["x"]][,2], labels = nom_SK) #PCA 1 vs 2

plot_PC2_SK <- plot(pca_SK, axis1=2, axis2=3)
text(pca_SK[["x"]][,2], pca_SK[["x"]][,3], labels = nom_SK) #PCA 1 vs 3

picknplot.shape(plot_SK) #generate deformation grid for a chosen specimen

PC.scores_SK <- pca_SK$x #save PC scores

as.data.frame(PC.scores_SK)

# Morphospace -------------------------------------
ggplot(as.data.frame(PC.scores_SK), aes(x=PC.scores_SK[,1], y=PC.scores_SK[,2], label = nom_SK, fontface = "italic")) +
  labs(fill="Periods") +
  coord_fixed(ratio = 1) +
  geom_point(aes(fill = Period_habitats_SK$`Period (R)`), color = "black", size = 6, shape = 21, stroke = 0.10)  +
  scale_fill_manual(values = cols)+
  lims(x=c(-0.5,0.5), y = c(-0.3,0.3)) +
  
  theme_bw() +
  theme(axis.text.x = element_text(size = 25, color="black", margin = margin(t = 5, r = 0, b = 0, l = 0)),
        axis.text.y = element_text(size = 25, color="black", margin = margin(t = 0, r = 5, b = 0, l = 0)), 
        axis.title.x = element_text(size = 29, margin = margin(t = 15, r = 0, b = 0, l = 0)), 
        axis.title.y = element_text(size = 29, margin = margin(t = 0, r = 15, b = 0, l = 0))) +
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(), legend.position = "none") +
  geom_text(hjust=0, vjust=0,color="black", size = 3) +
  labs(x = "PC1 = 32.24 %", y = "PC2 = 17.61 %" ) #PC 1 vs 2

# Morphological disparity: Procrustes variances ---------------------------------------------
# Import data
gdf_SK <- geomorph.data.frame(data.super_SK, species = Period_habitats_SK$Taxon, Time = Period_habitats_SK$`Period (R)`)
gdf_SK

SOV_SK <- morphol.disparity(coords~Time,groups=~Time, data = gdf_SK, iter = 999) #If you want to calculate the disparity within each group, and compare that to the disparity within other groups, this is the syntax. This tells me which time bin is most/least disparate

summary(SOV_SK)

# Graphical representation
SoV_SK <- c("0.05722401", "0.05516000", "NA", "0.03898736", "0.04811587", "0.04373271", "NA")
periods <- c("Devonian", "Carboniferous", "Permian", "Triassic", "Jurassic", "Cretaceous", "Extant")
SoV_SK <- as.numeric(as.character(SoV_SK))
periods <- as.factor(as.character(periods))

DF_SoV_SK <- data.frame(Periods = periods, SoV = SoV_SK)
DF_SoV_SK

level_order <- factor(DF_SoV_SK$Periods, level = c("Devonian", "Carboniferous", "Permian", "Triassic", "Jurassic", "Cretaceous", "Extant"))

ggplot(DF_SoV_SK, aes(x=level_order, y=SoV, group = 1)) +
  geom_line(color = "black") +
  geom_point()+
  scale_y_continuous(limits = c(0,0.06))+
  theme_bw()+
  theme(panel.border = element_blank(), panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(), axis.line = element_line(colour = "black"))

########################### Jaw Disparity ####################################
#  TPS file: 7 2D-landmarks and 38 species
Jaw <- readland.tps("Jaws.TPS",specID="imageID",negNA = TRUE,warnmsg = TRUE)
nom_Jaw <- dimnames(Jaw)[[3]]
dim(Jaw)

# Table Taxa x period
Period_habitats_Jaw <- read_excel(file.choose(), 1) #open age-habitat-jaw.xlsx
Period_habitats_Jaw

Period_habitats_Jaw <- Period_habitats_Jaw %>%
  mutate_if(is.character, as.factor)

new_jaw <- Period_habitats_Jaw[-15,] #remove L. menadoensis 

# Principal component analysis -------------------------------------------
# Procrustes superimposition
data.super_Jaw <- gpagen(Jaw, ProcD = FALSE)
attributes(data.super_Jaw)

plot(data.super_Jaw) 

# PCA 
pca_Jaw <- gm.prcomp(data.super_Jaw$coords)
pca_Jaw

plot_Jaw <- plot(pca_Jaw, axis1 = 1, axis2 = 2)
text(pca_Jaw[["x"]][,1], pca_Jaw[["x"]][,2], labels = nom_Jaw) #PCA 1 vs 2

plot_PC2_Jaw <- plot(pca_Jaw, axis1=2, axis2=3)
text(pca_Jaw[["x"]][,2], pca_Jaw[["x"]][,3], labels = nom_Jaw) #PCA 1 vs 3

picknplot.shape(plot_Jaw) #generate deformation grid for a chosen specimen

PC.scores_Jaw <- pca_Jaw$x #save PC scores

as.data.frame(PC.scores_Jaw)

ggplot(as.data.frame(PC.scores_Jaw), aes(x=PC.scores_Jaw[,1], y=PC.scores_Jaw[,2], label = nom_Jaw, fontface = "italic")) +
  labs(fill="Periods") +
  coord_fixed(ratio = 1) +
  geom_point(aes(fill = new_jaw$`Period (R)`), color = "black", size = 6, shape = 21, stroke = 0.10)  +
  scale_fill_manual(values = cols)+
  lims(x=c(-0.5,0.5), y = c(-0.3,0.3)) +
  
  theme_bw() +
  theme(axis.text.x = element_text(size = 25, color="black", margin = margin(t = 5, r = 0, b = 0, l = 0)),
        axis.text.y = element_text(size = 25, color="black", margin = margin(t = 0, r = 5, b = 0, l = 0)), 
        axis.title.x = element_text(size = 29, margin = margin(t = 15, r = 0, b = 0, l = 0)), 
        axis.title.y = element_text(size = 29, margin = margin(t = 0, r = 15, b = 0, l = 0))) +
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(), legend.position = "none") +
  geom_text(hjust=0, vjust=0,color="black", size = 3) +
  labs(x = "PC1 = 33.85 %", y = "PC2 = 19.64 %" ) #PC 1 vs 2


# Morphological disparity: Procrustes variances ---------------------------------------------
# Import data
gdf_Jaw <- geomorph.data.frame(data.super_Jaw, species = new_jaw$Taxon, Time = new_jaw$`Period (R)`)
gdf_Jaw

# Procrustes variances
SOV_Jaw <- morphol.disparity(coords~Time,groups=~Time, data = gdf_Jaw, iter = 999) #If you want to calculate the disparity within each group, and compare that to the disparity within other groups, this is the syntax. This tells me which time bin is most/least disparate
summary(SOV_Jaw)

# Graphical representation
SoV_Jaw <- c("0.02473686", "0.0227300", "NA", "0.02507682", "0.02829043", "0.01423118", "NA")
periods <- c("Devonian", "Carboniferous", "Permian", "Triassic", "Jurassic", "Cretaceous", "Extant")
SoV_Jaw <- as.numeric(as.character(SoV_Jaw))
periods <- as.factor(as.character(periods))

DF_SoV_Jaw <- data.frame(Periods = periods, SoV = SoV_Jaw)
DF_SoV_Jaw

level_order <- factor(DF_SoV_Jaw$Periods, level = c("Devonian", "Carboniferous", "Permian", "Triassic", "Jurassic", "Cretaceous", "Extant"))

ggplot(DF_SoV_Jaw, aes(x=level_order, y=SoV, group = 1)) +
  geom_line(color = "black") +
  geom_point()+
  scale_y_continuous(limits = c(0,0.06))+
  theme_bw()+
  theme(panel.border = element_blank(), panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(), axis.line = element_line(colour = "black"))

# Combining PC, Skull, and Jaw disparity ---------------------------------------------
SoV_PC <- c("0.014607552", "0.032271062", "0.003859100", "0.021567889", "0.012613369", "0.006396594", "0.002598122")
SoV_SK <- c("0.05722401", "0.05516000", "NA", "0.03898736", "0.04811587", "0.04373271", "NA")
SoV_Jaw <- c("0.02473686", "0.0227300", "NA", "0.02507682", "0.02829043", "0.01423118", "NA")
periods <- c("Devonian", "Carboniferous", "Permian", "Triassic", "Jurassic", "Cretaceous", "Extant")
SoV_PC <- as.numeric(as.character(SoV_PC))
SoV_SK <- as.numeric(as.character(SoV_SK))
SoV_Jaw <- as.numeric(as.character(SoV_Jaw))
periods <- as.factor(as.character(periods))

DF_SoV <- data.frame(Periods = periods, SoV_PC = SoV_PC, SoV_SK = SoV_SK, SoV_Jaw = SoV_Jaw)
DF_SoV

level_order <- factor(DF_SoV$Periods, level = c("Devonian", "Carboniferous", "Permian", "Triassic", "Jurassic", "Cretaceous", "Extant"))

ggplot(DF_SoV, aes(x=level_order, group = 1)) +
  geom_point(aes(y = SoV_PC), color = "black", size = 4) +
  geom_line(aes(y = SoV_PC), color = "black", size = 1.5) +
  geom_point(aes(y = SoV_SK), color = "red", size = 4) +
  geom_line(aes(y=SoV_SK), color = "red", size = 1.5) +
  geom_point(aes(y = SoV_Jaw), color = "blue", size = 4) +
  geom_line(aes(y=SoV_Jaw), color = "blue", size = 1.5) +
  
  scale_y_continuous(limits = c(0,0.06))+
  
  theme(axis.title.x=element_blank(), 
        axis.title.y = element_text(color="black", size=55, family = "sans", margin = margin(t = 0, r = 25, b = 0, l = 0)), 
        axis.text.x = element_text(color="black", size=55, margin = margin(t = 15,r = 0, b = 0, l = 0)), 
        axis.text.y = element_text(color="black", size=42, margin = margin(t = 0, r = 10, b = 0, l = 0))) +
  ylab("Procrustes variance") +
  
  theme(panel.border = element_blank(), panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(), axis.line = element_line(colour = "black", size = 0.5), panel.background = element_blank())
