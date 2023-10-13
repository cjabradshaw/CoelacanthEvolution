setwd(dirname(rstudioapi::getSourceEditorContext()$path))
library(dispRity)
library(phylotate)
library(geoscale)
library(phytools)
source("functions.R")
#this is a very small sample of trees, for demonstration only, not the same as used in the paper
file <- "Coelacanths_87_268_tipsVariance_Dis_Mer_Con_uclnG_RootExp418_MC3_sumBi20_thinned.trees"
trees <- read_annotated(file)
onych <- c("Qingmenodus_yui", "Strunius_rolandi", "Strunius_walteri", "Onychodus_jandemarrai", "Grossius_aragonensis")

# list of tables. each list member corresponds to a tree
# in the table, each row corresponds to branch, in the order of tree$edge
# columns refer to start date and end date of branch, and the discrete, continuous and meristic rates
ratetables <- lapply(trees, make_rate_table)
living_branches_rates <- extinct_branch_rates <- ratetables
# get a list, where each member is a vector
# each vector is the edges that need to be excluded because they occur within onychodonts
edg <- lapply(trees, get_clade_edges, taxa=onych)

#keep only branches leading to living taxa
paths_to_living <- lapply(trees, path_to_living)
for(i in 1:length(living_branches_rates)){
  living_branches_rates[[i]] <- living_branches_rates[[i]][(paths_to_living[[i]]),]
}

# keep only branches leading to extinct taxa, remove those leading to onychodonts
# these can be different depending on the tree, so the correct branches for each tree are taken from the edg list
for(i in 1:length(ratetables)){
  extinct_branch_rates[[i]] <- ratetables[[i]][-c(paths_to_living[[i]], edg[[i]]),]
}


# remove rows that correspond to the onychodont branches.
# these can be different depending on the tree, so the correct branches for each tree are taken from the edg list
for(i in 1:length(ratetables)){
  ratetables[[i]] <- ratetables[[i]][-(edg[[i]]),]
}


# ages based on ICS chart 2022-10
epochs <- data.frame(Period=c("Silurian","Devonian", "Carboniferous", "Permian", "Triassic", "Jurassic", "Creataceous", "Cenozoic"),
                     Lower=c(443.8, 419.2, 358.9, 298.9, 251.9, 201.4, 145, 66),
                     Upper=c(419.2, 358.9, 298.9, 251.9, 201.4, 145, 66, 0))


# tables have new columns added, one for each time period
# the value corresponds to how much of each branch is in each time period
all_tables <- lapply(ratetables, make_overlap_table)

# table of weighted means. Each row corresponds to a tree
# columns refer to the weighted mean rate in each time period
wm_table_discrete <- do.call(rbind, lapply(all_tables, get_all_weighted_means, rate.class="discrete.rate", epochs=epochs))
wm_table_continuous <- do.call(rbind, lapply(all_tables, get_all_weighted_means, rate.class="continuous.rate", epochs=epochs))
wm_table_meristic <- do.call(rbind, lapply(all_tables, get_all_weighted_means, rate.class="meristic.rate", epochs=epochs))

# get the midpoint of each period, for plotting
midages <- apply(epochs[,2:3], 1, mean)
par(family="Arial")

pdf(file="discrete.pdf", width=12, height=8)
make_fancy_plot("discrete.rate", wm_table_discrete, ymax=0.04)
legend(legend=c("branches with living descendants", "branches without living descendants"), x="topright", col=c("#5c7de0", "black"), border=NA, lty=1, lwd=2, bty="n")
title(main="Discrete characters", line=-1, font.main=1)
dev.off()

pdf(file="continuous.pdf", width=12, height=8)
make_fancy_plot("continuous.rate", wm_table_continuous, ymax=5)
legend(legend=c("branches with living descendants", "branches without living descendants"), x="topright", col=c("#5c7de0", "black"), border=NA, lty=1, lwd=2, bty="n")
title(main="Continuous characters", line=-1, font.main=1)
dev.off()

pdf(file="meristic.pdf", width=12, height=8)
make_fancy_plot("meristic.rate", wm_table_meristic, ymax=5)
legend(legend=c("branches with living descendants", "branches without living descendants"), x="topright", col=c("#5c7de0", "black"), border=NA, lty=1, lwd=2, bty="n")
title(main="Meristic characters", line=-1, font.main=1)
dev.off()
