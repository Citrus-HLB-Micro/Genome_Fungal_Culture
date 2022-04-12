#!/bin/bash -l
#SBATCH --nodes 1 --ntasks 8 --mem 16G --time 24:00:00 --out logs/busco_1_%a.log -J busco
# This generates summary BUSCO for the genome assemblies
# # This expects to be run as slurm array jobs where the number passed into the array corresponds
# to the line in the samples.info file
module load busco
module load workspace/scratch

# for augustus training
export AUGUSTUS_CONFIG_PATH=/bigdata/stajichlab/shared/pkg/augustus/3.3/config

CPU=${SLURM_CPUS_ON_NODE}
N=${SLURM_ARRAY_TASK_ID}
if [ ! $CPU ]; then
     CPU=2
fi

if [ ! $N ]; then
    N=$1
    if [ ! $N ]; then
        echo "Need an array id or cmdline val for the job"
        exit
    fi
fi

if [ -z ${SLURM_ARRAY_JOB_ID} ]; then
        SLURM_ARRAY_JOB_ID=$$
fi
GENOMEFOLDER=genomes
EXT=sorted.fasta
OUTFOLDER=BUSCO
SAMPLEFILE=samples.csv
LINEAGE=sordariomycetes_odb10
NAME=$(sed -n ${N}p $SAMPLEFILE | awk -F, '{print $2}')
SEED_SPECIES=fusarium_solani
GENOMEFILE=$(realpath $GENOMEFOLDER/${NAME}.${EXT})
mkdir -p $OUTFOLDER
if [ -d "$OUTFOLDER/${NAME}" ];  then
    echo "Already have run $NAME in folder busco - do you need to delete it to rerun?"
    exit
else
   busco -m genome -l $LINEAGE -c $CPU -o $NAME --out_path $OUTFOLDER --offline --download_path $BUSCO_LINEAGES --augustus_species $SEED_SPECIES \
	   --in $GENOMEFILE
fi

