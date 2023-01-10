#!/usr/bin/bash -l
#SBATCH --ntasks 2 --mem 120G --time 24:00:00 -N 1

module load muscle
module load fasttree

muscle -super5 TEF1_short.fa -output TEF1_short.aln
fasttree <TEF1_short.aln> TEF1_short.tre
