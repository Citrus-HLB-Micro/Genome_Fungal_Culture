#!/bin/bash -l
#SBATCH -p short -N 1 -n 32 --mem 64gb --out phykit_summarize.log

CPU=1
if [ $SLURM_CPUS_ON_NODE ]; then
  CPU=$SLURM_CPUS_ON_NODE
fi

source config.txt
PEPTREEEXT=aa.clipkit.FT.tre
mkdir -p gene_trees
pushd gene_trees
ln -s ../aln/$HMM/*.${PEPTREEEXT} .

module load phykit
module load parallel
summarize() {
	treefile = $1
	aln      = $(basename $1 .FT.tre)
	len      = $(phykit aln_len $aln)
	bss      = $(phykit bss $aln)
	meanBSS   = $(echo $bss | grep mean: | awk '{print $2}')
	medianBSS = $(echo $bss | grep median: | awk '{print $2}')

	echo -e "$treefile\t$aln\t$len\t$meanBSS\t$medianBSS\t"
}
export -f summarize
echo -e "TREE\tALN\tALNLEN\tmean_BSS\tmedian_BSS" > ../gene_trees.summarize_PEP.tsv
parallel -j $CPU summarize ::: $(ls *.${PEPTREEEXT}) >> ../gene_trees.summarize_PEP.tsv
