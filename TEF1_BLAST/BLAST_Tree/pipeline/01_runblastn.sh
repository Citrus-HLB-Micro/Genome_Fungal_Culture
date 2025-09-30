#!/bin/bash
#SBATCH --nodes 1 --ntasks 2 --mem 8G -p short --out logs/blastn_%a.log

module load ncbi-blast

# EXPECTED VARIABLES
GENOMEFOLDER=genomes
BLAST=blastn
mkdir -p $BLAST
SAMPLES=strains.csv
GENE=TEF1
#GENE=NRRL_44887_FFSC_Asian_fujikuroi_Human_USA_inf

if [ $SLURM_CPUS_ON_NODE ]; then
 CPU=$SLURM_CPUS_ON_NODE
fi
N=${SLURM_ARRAY_TASK_ID}

if [ ! $N ]; then
 N=$1
 if [ ! $N ]; then 
    echo "Need a number via slurm --array or cmdline"
    exit
 fi
fi

IFS=,
sed -n ${N}p $SAMPLES | while read STRAIN
do
	blastn -db $GENOMEFOLDER/$STRAIN -query $GENE.fa -evalue 1e-5  -outfmt 6 -out $BLAST/$STRAIN.$GENE.blastn.tab
done
