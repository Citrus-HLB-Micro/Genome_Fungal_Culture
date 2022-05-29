#!/usr/bin/bash -l
#SBATCH -p short -N 1 -n 16 --mem 8gb --out logs/download_sra.%a.log -a 1-3

module load parallel-fastq-dump
module load workspace/scratch

CPU=2
if [ $SLURM_CPUS_ON_NODE ]; then
  CPU=$SLURM_CPUS_ON_NODE
fi
N=${SLURM_ARRAY_TASK_ID}
if [ -z $N ]; then
  N=$1
fi
if [ -z $N ]; then
  echo "cannot run without a number provided either cmdline or --array in sbatch"
  exit
fi
SRAFILE=sra.txt
FOLDER=input

MAX=$(wc -l $SRAFILE | awk '{print $1}')
if [ $N -gt $MAX ]; then
  echo "$N is too big, only $MAX lines in $SRAFILE"
  exit
fi
if [ ! -s $SRAFILE ]; then
	echo "No SRA file $SRAFILE"
	exit
fi
SRA=$(sed -n ${N}p $SRAFILE | cut -f1)
if [ ! -s ${SRA}_1.fastq.gz ]; then
	parallel-fastq-dump --defline-seq '@$sn[_$rn]/$ri'  -T $SCRATCH -O $SRA --threads $CPU --split-files --gzip --sra-id $SRA
fi
