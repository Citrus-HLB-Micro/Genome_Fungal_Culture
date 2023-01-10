#!/bin/bash
#SBATCH --nodes 1 --ntasks 2 --mem 8G -p short --out logs/blastp_%a.log

module load ncbi-blast

# EXPECTED VARIABLES
GENOMEFOLDER=pep
BLAST=blastp
mkdir -p $BLAST
SAMPLES=strains.csv
QUERY=Fried.AIP1.faa

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
sed -n ${N}p $SAMPLES | while read STRAIN BUSCO
do
	blastp -db $GENOMEFOLDER/$STRAIN -query $QUERY -evalue 1e-5  -outfmt 6 -out $BLAST/$STRAIN.$QUERY.tab
done
