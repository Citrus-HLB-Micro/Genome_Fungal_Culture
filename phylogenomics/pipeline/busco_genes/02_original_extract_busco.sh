#!/usr/bin/bash -l
#SBATCH -p short -N 1 -n 24 --mem 2gb --out logs/gather_busco_seqs.%a.log

module load parallel
CPU=1
if [ $SLURM_CPUS_ON_NODE ]; then
  CPU=$SLURM_CPUS_ON_NODE
fi
INDIR=BUSCO
OUTCDS=cds
OUTPEP=pep
INCLUDEFRAG=1
INCLUDEMULTI=0
mkdir -p $OUTCDS $OUTPEP
rename() {
  file=$1
  seqname=$(basename $file)
  perl -p -e "s/>/>$seqname /" $file
}
export -f rename
# could use parallel to speed this up...
# but may be I/O bound anyways
N=${SLURM_ARRAY_TASK_ID}

if [ -z $N ]; then
  N=$1
  if [ -z $N ]; then
    echo "need to provide a number by --array or cmdline"
    exit
  fi
fi
d=$(ls $INDIR | sed -n ${N}p)

species=$(basename $d)
d=$INDIR/$d
if [ ! -s $OUTPEP/$species.aa.fa ]; then
    time parallel -j $CPU rename ::: $(ls $d/run*/busco_sequences/single_copy_busco_sequences/*.faa) > $OUTPEP/$species.aa.fa
    time parallel -j $CPU rename ::: $(ls $d/run*/busco_sequences/single_copy_busco_sequences/*.fna) > $OUTCDS/$species.cds.fa
    if [ $INCLUDEFRAG ]; then
     	parallel rename ::: $(ls $d/run*/busco_sequences/fragmented_busco_sequences/*.faa) >> $OUTPEP/$species.aa.fa
     	parallel rename ::: $(ls $d/run*/busco_sequences/fragmented_busco_sequences/*.fna) >> $OUTCDS/$species.cds.fa
    fi
    if [ $INCLUDEMULTI ]; then
     	parallel rename ::: $(ls $d/run*/busco_sequences/multi_copy_busco_sequences/*.faa) >> $OUTPEP/$species.aa.fa
     	parallel rename ::: $(ls $d/run*/busco_sequences/multi_copy_busco_sequences/*.faa) >> $OUTPEP/$species.aa.fa
    fi
fi
