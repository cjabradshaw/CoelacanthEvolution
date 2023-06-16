rates_df <- function(vec) {
  # split each string by the "=" character
  ratelist <- lapply(vec, function(x) unlist(strsplit(x, "=")))
  # create a data frame with the resulting substrings as columns
  dfrate <- as.data.frame(do.call(cbind, ratelist), stringsAsFactors = FALSE)
  colnames(dfrate) <- dfrate[1,]
  dfrate <- dfrate[-1,]
  # return the resulting data frame
  return(dfrate)
}

#
make_rate_table <- function(tree){
  ano <- strsplit(tree$node.comment, ",")
  ano <- ano[tree$edge[,2]]
  ano2 <- lapply(ano, function(x) x[grep(paste("continuous", "meristic", "discrete", sep = "|"), x)])
  ano3 <- lapply(ano2, rates_df)
  rates <- do.call(rbind, ano3)
  ages <- tree.age(tree)[,1]
  edges <- tree$edge
  edges[,1] <- ages[edges[,1]]
  edges[,2] <- ages[edges[,2]]
  edgerates <- cbind(edges, rates)
  return(edgerates)
}

# calculates the overlap between two ranges
overlap <- function(x, y) {
  # Calculate the range of overlap
  overlap_start <- min(x[1], y[1])
  overlap_end <- max(x[2], y[2])
  # Calculate the amount of overlap
  overlap_amount <- overlap_start-overlap_end
  # Return the amount of overlap (or 0 if there is no overlap)
  return(max(0, overlap_amount))
}

# gets the amount that each branch overlaps with a given Period
epoch_overlap <- function(epoch, table){
  ol <- vector()
  ind <- which(epochs[,1]==epoch)
  for(i in 1:nrow(table)){
    ol[i] <- overlap(table[i,1:2], epochs[ind,2:3])
  }
  return(ol)
}

# makes table where rows are branches and columns have the rates and the amount that each branch overlaps with each time period
make_overlap_table <- function(x){
  period_overlaps <- lapply(epochs$Period, epoch_overlap, table=x)
  names(period_overlaps) <- epochs$Period
  y <- as.data.frame(period_overlaps)
  z <- cbind(x, y)
  return(z)
}

get_weighted_mean <- function(Period, table, rate.class="discrete.rate") {
  lengthrates <- table[,Period]*as.numeric(table[,rate.class])
  wm <- sum(lengthrates)/sum(table[,Period])
  return(wm)
}

get_all_weighted_means <- function(table, rate.class, epochs){
  wms <- unlist(lapply(epochs$Period, get_weighted_mean, table=table, rate.class=rate.class))
  names(wms) <- epochs$Period
  return(wms)
}

# plots the weighted means on the geological timescale
geoplot.epoch.rates <- function(wm_table, epochs, line.col="black", plot.mean=T, mean.col="red", plot.bounds=T, ...){
  midages <- apply(epochs[,2:3], 1, mean) -> midages
  geoscalePlot(ages=rev(midages), data=rev(wm_table[1,]), data.lim=c(min(wm_table), max(wm_table)), type="n", label="rate", ...)
  if(plot.bounds == TRUE)
    abline(v=epochs[,3], lty=3)
  for(i in 1:nrow(wm_table)){
    lines(midages[1:length(midages)], wm_table[i,1:length(midages)], col=line.col, lwd=0.05)
  }
  if(plot.mean == TRUE)
    lines(midages[1:length(midages)], apply(wm_table, 2, mean), col=mean.col, lwd=3)
}

# gets the indices of the edges (branches) that occur within a particular clade.
# includes branch leading to common ancestor
get_clade_edges <- function(tree, taxa){
  nodes <- c(getMRCA(tree, taxa), getDescendants(tree, getMRCA(tree, taxa)))
  edges <- which(tree$edge[,2] %in% nodes)
}

#find the edge indices on the path leading to living coelacanths
path_to_living <- function(tree){
  x <- nodes <- getMRCA(tree, c("Latimeria_chalumnae", "Latimeria_menadoensis"))
  livingind <- getDescendants(tree, x)
  while(!is.null(x)){
    x <- getParent(tree, x)
    nodes <- append(nodes, x)
  }
  nodes_to_living <- c(livingind, nodes[1:(length(nodes)-1)])
  edg_to_living <- which(tree$edge[,2] %in% nodes_to_living)
  return(edg_to_living)
}

#plots branch rates of a tree as faint horizontal lines
# when looped over multiple tree it gives the impression of a density map of rates
plot_branch_lines <- function(df, rate_class="discrete.rate", col="#00000005"){
  for (i in 1:nrow(df)) {
    lines(c(df[i, 1], df[i, 2]), c(df[i, rate_class], df[i, rate_class]), col=col)
  }
}

#make the plots for a given type of rate
make_fancy_plot <- function(rate_class="discrete.rate", wm_table, ymax, ...){
  geoscalePlot(ages=rev(midages), data=rev(wm_table[1,]), data.lim=c(0, ymax), type="n", label="rate", age.lim=c(max(epochs[,2]), 0), units=c("Period", "Epoch"), tick.scale=1000000, cex.ts=1, ...)
  lapply(extinct_branch_rates, plot_branch_lines, rate_class=rate_class)
  lapply(living_branches_rates, plot_branch_lines, col="#5c7de010", rate_class=rate_class)
  period_cols <- c("#b3e1b6", "#cb8c37", "#67a599", "#f04028", "#812b92", "#34b2c9", "#7fc64e", "#fd9a52")
  for(i in 1:length(midages)){
    boxplot(wm_table[,i], add=T, at=midages[i], boxwex=10, col="#c16a74", border="white", range=0, lty=1, lwd=6, axes=FALSE)
  }
  for(i in 1:length(midages)){
    boxplot(wm_table[,i], add=T, at=midages[i], boxwex=10, col=period_cols[i], border=period_cols[i], range=0, lty=1, lwd=2.5, axes=FALSE)
  }
}
