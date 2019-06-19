#!/usr/bin/perl -w

use strict;
#
# script AGPFILE FASTA
# Author: Tyler Alioto
# email: tyler.alioto@cnag.crg.eu

use Bio::DB::Fasta;
use Bio::Seq;
use Bio::SeqIO; 
open(AGP,shift()) or die $!;
my %chr;

my $fasta=shift;
if (!-e "$fasta.index"){
`indexGenome.pl -f $fasta`;
}
my $db = Bio::DB::Fasta->new($fasta);
my $seq_out = Bio::SeqIO->new('-fh' => \*STDOUT,'-format' => 'fasta');
my $lastid=0;
my $last_seq='';
while(<AGP>){
    chomp;
	next if m/^#/;
	next if m/^\s/;
	my @F = split /\s+/;

	$lastid=$F[0] unless $lastid;

    if ($F[0] ne $lastid){
	#print STDERR  "$lastid\n";	
	print_seq($lastid,$last_seq);
	 	$lastid=$F[0];
        $last_seq='';
	}


	# extend temp string if it's too short
	do{$last_seq.= ' ' x 1_000_000;} while length $last_seq < $F[2] ;
	if($F[4] !~ m/(N|U)/i){
		my ($start,$stop) = $F[8] ne '-'?($F[6], $F[7]):($F[7], $F[6]);
		#print STDERR "substr $last_seq, $F[1], $F[7], ",'$db->seq',"($F[5],$start,$stop);\n";
		#print STDERR $db->seq($F[5],$start,$stop),"\n";
		print STDERR (join "\t",($F[5],$start,$stop)),"\n";
		my $s = substr($last_seq, $F[1], $F[7], $db->seq($F[5],$start,$stop));
	}elsif($F[5]){
	    my $s = substr $last_seq, $F[1], $F[5], "N" x $F[5] ;
	}
} 

print_seq($lastid,$last_seq);

sub print_seq{
    my($id,$seq)=@_;	
	$seq=~s/\s+//g;
    my $seqobj = Bio::Seq->new( -display_id => "$id", -seq => $seq);
    $seq_out->write_seq($seqobj);
}
