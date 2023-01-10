#!/usr/bin/perl
#
use File::Spec;
use strict;
use warnings;

my %stats;


my $telomere_report = 'reports';
my $read_map_stat = 'mapping_report';
my $dir = shift || 'genomes';
my %cols;
my @header;
my %header_seen;

opendir(DIR,$dir) || die $!;
my $first = 1;
foreach my $file ( readdir(DIR) ) {
    next unless ( $file =~ /(\S+)(\.fasta)?\.stats.txt$/);
    my $stem = $1;
    $stem =~ s/\.sorted//;
    warn("$file ($dir)\n");
    open(my $fh => "$dir/$file") || die "cannot open $dir/$file: $!";
    while(<$fh>) {
	next if /^\s+$/;
	s/^\s+//;
	chomp;
	if ( /\s*(.+)\s+=\s+(\d+(\.\d+)?)/ ) {
	    my ($name,$val) = ($1,$2);	    
	    $name =~ s/\s*$//;
	    $stats{$stem}->{$name} = $val;
#	    warn("'$name'"," '", $val,"'\n");
	    $cols{$name}++;
	    if( ! exists $header_seen{$name} ) {
		push @header, $name;
		$header_seen{$name} = 1;
	    }
	}
    }
    if ( $first ) { 
	push @header, qw(BUSCO_Complete BUSCO_Single BUSCO_Duplicate
                 BUSCO_Fragmented BUSCO_Missing BUSCO_NumGenes
                 );
    }
   
    if ( -d $telomere_report ) {

	if ( $first ) {
	    push @header, qw(Telomeres_Found Telomeres_Fwd Telomeres_Rev Telomeres_CompleteChrom);
	}
	my $telomerefile = File::Spec->catfile($telomere_report,sprintf("%s.scaffolds.telomere_report.txt",$stem));
  	if ( ! -f $telomerefile ) {
		$telomerefile = File::Spec->catfile($telomere_report,sprintf("%s.scaffolds.telomere_report.txt",$stem));
	}
	if ( -f $telomerefile ) {
	    open(my $fh => $telomerefile) || die $!;
	    my %contigs_with_tel;
	    while(<$fh>) {
		if( /^(\S+)\s+(forward|reverse)\s+(\S+)/i ){
		    $contigs_with_tel{$1}->{$2} = $3;
		} elsif (/^Telomeres found:\s+(\d+)\s+\((\S+)\s+forward,\s+(\S+)\s+reverse\)/ ) {
		    $stats{$stem}->{'Telomeres_Found'} = $1;
		    $stats{$stem}->{'Telomeres_Fwd'} = $2;
		    $stats{$stem}->{'Telomeres_Rev'} = $3;
		}
	    }
	    for my $ctg ( keys %contigs_with_tel ) {
		if (exists $contigs_with_tel{$ctg}->{'forward'} &&
		    exists $contigs_with_tel{$ctg}->{'reverse'} ) {
		    $stats{$stem}->{'Telomeres_CompleteChrom'} +=1; # or ++ but count up the number of times we have a ctg w fwd&rev
		}
	    }
	}

    }    

    my $busco_file = File::Spec->catfile("BUSCO",sprintf("%s",$stem),
					 sprintf("short_summary.specific.dothideomycetes_odb10.%s.txt",$stem));

    if ( -f $busco_file ) {

	open(my $fh => $busco_file) || die $!;
	while(<$fh>) {	 
	    if (/^\s+C:(\d+\.\d+)\%\[S:(\d+\.\d+)%,D:(\d+\.\d+)%\],F:(\d+\.\d+)%,M:(\d+\.\d+)%,n:(\d+)/ ) {
		$stats{$stem}->{"BUSCO_Complete"} = $1;
		$stats{$stem}->{"BUSCO_Single"} = $2;
		$stats{$stem}->{"BUSCO_Duplicate"} = $3;
		$stats{$stem}->{"BUSCO_Fragmented"} = $4;
		$stats{$stem}->{"BUSCO_Missing"} = $5;
		$stats{$stem}->{"BUSCO_NumGenes"} = $6;
	    } 
	}

    } else {
	warn("Cannot find $busco_file");
    }

    my $sumstatfile = File::Spec->catfile($read_map_stat,
				      sprintf("%s.bbmap_summary.txt",$stem));
    if ( -f $sumstatfile ) {
	open(my $fh => $sumstatfile) || die "Cannot open $sumstatfile: $!";
	my $read_dir = 0;
	my $base_count = 0;
	$stats{$stem}->{'Mapped reads'} = 0;
	while(<$fh>) {
	    if( /Read (\d+) data:/) {
		$read_dir = $1;
	    } elsif( $read_dir && /^mapped:\s+(\S+)\s+(\d+)\s+(\S+)\s+(\d+)/) {
		$base_count += $4;
		$stats{$stem}->{'Mapped_reads'} += $2;
	    }  elsif( /^Reads:\s+(\S+)/) {
		$stats{$stem}->{'Reads'} = $1;
	    }
	    
	}
	$stats{$stem}->{'Average_Coverage'} =
	    sprintf("%.1f",$base_count / $stats{$stem}->{'TOTAL LENGTH'});
	if( $first )  {
	    push @header, ('Reads',
			   'Mapped_reads',			   
			   'Average_Coverage');
	}
    }
    
    $first = 0;
}

print join("\t", qw(SampleID), @header), "\n";
foreach my $sp ( sort keys %stats ) {    
    print join("\t", $sp, map { $stats{$sp}->{$_} || 'NA' } @header), "\n";
}
