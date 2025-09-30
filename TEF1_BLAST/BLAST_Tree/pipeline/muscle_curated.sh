#!/usr/bin/bash -l
#SBATCH --ntasks 2 --mem 120G --time 24:00:00 -N 1

module load muscle
module load fasttree

muscle -super5 TEF1_new.fna -output TEF1_new.aln
fasttree <TEF1_new.aln> TEF1_new.tre
