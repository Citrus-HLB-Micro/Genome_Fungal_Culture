#!/usr/bin/

BINDIR=bin
mkdir -p $BINDIR

if [ ! -f $BINDIR/datasets ]; then
	curl -o $BINDIR/dataformat https://ftp.ncbi.nlm.nih.gov/pub/datasets/command-line/LATEST/linux-amd64/dataformat
	curl -o $BINDIR/datasets https://ftp.ncbi.nlm.nih.gov/pub/datasets/command-line/LATEST/linux-amd64/datasets

	chmod +x $BINDIR/dataformat $BINDIR/datasets
fi
ACCESSION=lib/ncbi_accessions.json
INGROUP=lib/ingroups.NCBI.csv
OUTGROUP=lib/outgroups.csv

cut -d, -f4 $INGROUP | sort | uniq > bioprojects.$$

if [ ! -s $ACCESSION ]; then
	$BINDIR/datasets summary genome accession  --inputfile bioprojects.$$ > $ACCESSION
fi
cut -d, -f3 $OUTGROUP | tail -n +2 | sort | uniq > bioprojects.$$
ACCESSION=lib/ncbi_accessions_outgroups.json
$BINDIR/datasets summary genome accession  --inputfile bioprojects.$$ > $ACCESSION
if [ ! -s $ACCESSION ]; then
        $BINDIR/datasets summary genome accession  --inputfile bioprojects.$$ > $ACCESSION
fi
#unlink bioprojects.$$
