#!/usr/bin/bash
#SBATCH -p short -N 1 -n 32 --mem 64gb --out phykit_summarize.log

CPU=1
if [ $SLURM_CPUS_ON_NODE ]; then
  CPU=$SLURM_CPUS_ON_NODE
fi


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
echo -e "TREE\tALN\tALNLEN\tmean_BSS\tmedian_BSS"
parallel -j $CPU summarize ::: $(ls *.FT.tre)
