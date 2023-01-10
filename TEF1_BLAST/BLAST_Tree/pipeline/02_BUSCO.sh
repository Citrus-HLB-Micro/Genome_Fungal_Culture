#!/usr/bin/bash -l
#SBATCH -p short -C xeon -n16 -N1 --mem 128gb --out logs/busco.%a.log

module load busco/5.3.2
BUSCODB=/srv/projects/db/BUSCO/v10/lineages/
LINEAGE=$BUSCODB/

TEMP=/scratch/${SLURM_ARRAY_JOB_ID}_${N}
mkdir -p $TEMP

SAMPLEFILE=strains.csv

N=${SLURM_ARRAY_TASK_ID}

if [ ! $N ]; then
    N=$1
    if [ ! $N ]; then
        echo "need to provide a number by --array or cmdline"
        exit
    fi
fi

NAME=$(sed -n ${N}p $SAMPLEFILE | awk -F, '{print $1}')
PHYLUM=$(sed -n ${N}p $SAMPLEFILE | awk -F, '{print $2}')

SEED_SPECIES=anidulans
LINEAGE=$(realpath $LINEAGE/$PHYLUM)
IN=cds
OUT=BUSCO
export AUGUSTUS_CONFIG_PATH=/bigdata/stajichlab/shared/pkg/augustus/3.3/config
CPU=1
if [ $SLURM_CPUS_ON_NODE ]; then
  CPU=$SLURM_CPUS_ON_NODE
fi

INFILE=$(realpath $IN/$NAME.scaffolds.fa)
BASE=$(basename $INFILE .scaffolds.fa)

if [ ! -d $OUT/$BASE ]; then
  module load busco/5.3.2
  busco -m genome -l $LINEAGE -c $CPU -o $BASE --out_path $OUT --offline --augustus_species aspergillus_nidulans --in $INFILE --download_path $BUSCO_LINEAGES
fi
	
if [ ! -s $IN/$BASE.stats.txt ]; then	
	module load AAFTF
  	AAFTF assess -i $INFILE -r $IN/$BASE.stats.txt
fi
