#!/usr/bin/bash
# this script lists datasets where BUSCO or make_CDS is needed to be run
# and gives the array job Ids necessary
N=1
DAT=()
CDS=()
for n in $(ls genomes/*.dna.fasta)
do
	b=$(basename $n .dna.fasta)
	if [ ! -d BUSCO/$b ]; then
		DAT+=( $N )
	fi
	N=$(expr $N + 1)
done

N=1
for n in $(ls BUSCO | sort) 
do
	if [ ! -s cds/$n.cds.fasta ]; then
		CDS+=( $N )
		echo "need to run $n is not in cds/$n.cds.fasta"
	fi
	N=$(expr $N + 1)
done
printf -v joined '%s,' "${DAT[@]}"

echo "sbatch -a ${joined%,} pipeline/02_busco.sh"
printf -v joined '%s,' "${CDS[@]}"
echo "sbatch -a ${joined%,} pipeline/03_make_CDS_from_busco.sh"
