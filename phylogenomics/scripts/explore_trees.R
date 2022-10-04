library(tidyverse)
library(purrr)
library(readr)
library(fs)
library(dplyr)
library(stringr)
library(binr)
#library(ggplot2)
#library(RColorBrewer)
#library(scales)
#library(viridis)

args = commandArgs(trailingOnly=TRUE)
outdir="."
if (length(args) >=1 ) {
  outdir=args[2]
}
treeinfoAA <- read_tsv("gene_trees.summarize_PEP.tsv")
treeinfoCDS <- read_tsv("gene_trees.summarize_CDS.tsv")

#hist(treeinfoAA$evoRate,100)
#hist(treeinfoCDS$evoRate,100)

#plot(treeinfoAA$ALNLEN,treeinfoAA$mean_BSS)
#plot(treeinfoAA$ALNLEN,treeinfoAA$evoRate)

#plot(treeinfoCDS$ALNLEN,treeinfoCDS$mean_BSS)
#plot(treeinfoCDS$ALNLEN,treeinfoCDS$evoRate)

#alnL <-quantile(quantile(treeinfoCDS$ALNLEN))
#filteredCDS <- treeinfoCDS %>% filter(ALNLEN >= alnL[4])
#evoR <-quantile(quantile(filteredCDS$evoRate))

#filteredCDS2 <-filteredCDS %>% filter(evoRate <= evoR[1] | evoRate >= evoR[4])
#write_tsv(filteredCDS2,file.path(outdir,"filtered_quartileLenEvoRate_CDS.tsv"))


# generate the bins
#alnL <-bins(treeinfoCDS$ALNLEN,10)
#filteredCDS <- treeinfoCDS %>% filter(ALNLEN >= alnL[4])
treeinfoCDS$evocat <- cut(treeinfoCDS$evoRate,breaks=5,
               labels=1:5)
table(treeinfoCDS$evocat)

treeinfoCDS$lencat <- cut(log(treeinfoCDS$ALNLEN),breaks=5,
                          labels=1:5)
table(treeinfoCDS$lencat)
treeinfoCDS

plot(log(treeinfoCDS$ALNLEN),treeinfoCDS$evoRate)

#filteredCDS2 <-treeinfoCDS %>% filter(evoRate <= evoR[1] | evoRate >= evoR[4])
#write_tsv(filteredCDS2,file.path(outdir,"filtered_quartileLenEvoRate_CDS.tsv"))



#alnL <-quantile(quantile(treeinfoAA$ALNLEN))
#filteredAA <- treeinfoAA %>% filter(ALNLEN >= alnL[4])
#evoR <-quantile(quantile(filteredAA$evoRate))
#filteredAA2 <-filteredAA %>% filter(evoRate <= evoR[1] | evoRate >= evoR[4])
#write_tsv(filteredAA2,file.path(outdir,"filtered_quartileLenEvoRate_AA.tsv"))
