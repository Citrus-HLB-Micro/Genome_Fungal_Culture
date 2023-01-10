#!/usr/bin/bash -l

#SBATCH --nodes 1 -p batch --ntasks 16 --mem 120gb --out logs/IQtree_curated.%A.log

module load IQ-TREE/2.2.0
module unload perl
module load miniconda3

iqtree2 -nt 2 -s TEF1_short.aln -b 1000
