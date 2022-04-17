#!/usr/bin/bash
#SBATCH --nodes 1 --ntasks 32 --mem 96gb --time 24:00:00 -p intel --out fasttree_run.%A.log

module load fasttree
NUM=$(wc -l prefix.tab | awk '{print $1}')
source config.txt

ALN=$PREFIX.subset.${NUM}_taxa.$HMM.cds.fasaln
TREE1=$PREFIX.subset.${NUM}_taxa.$HMM.cds.ft_lg.tre
TREE2=$PREFIX.subset.${NUM}_taxa.$HMM.cds.ft_lg_long.tre
if [ ! -s $TREE1 ]; then
	FastTreeMP -nt -gtr -gamma < $ALN > $TREE1
	echo "ALN is $ALN"
	if [ -s $TREE1 ]; then
		perl PHYling_unified/util/rename_tree_nodes.pl $TREE1 prefix.tab > $TREE2
	fi
fi
ALN=$PREFIX.subset.${NUM}_taxa.$HMM.aa.fasaln
TREE1=$PREFIX.subset.${NUM}_taxa.$HMM.aa.ft_lg.tre
TREE2=$PREFIX.subset.${NUM}_taxa.$HMM.aa.ft_lg_long.tre

if [ ! -s $TREE1 ]; then
	FastTreeMP -lg -gamma < $ALN > $TREE1
	if [ -s $TREE1 ]; then
		 perl PHYling_unified/util/rename_tree_nodes.pl $TREE1 prefix.tab > $TREE2
	fi
fi
