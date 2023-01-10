#!/usr/bin/bash -l
#SBATCH --ntasks 2 --mem 120G --time 24:00:00 -N 1

module load muscle
module load fasttree

muscle -super5 FUSARIUM.TEF1_formatted.fna -output FUSARIUM.TEF1_formatted.aln
fasttree <FUSARIUM.TEF1_formatted.aln> FUSARIUM.TEF1_formatted.tre
