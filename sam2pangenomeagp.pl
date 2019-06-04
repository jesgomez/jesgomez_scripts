#!/usr/bin/perl

use strict;
use warnings;
use Getopt::Long;

##Author: Jessica Gomez Garrido
#email: jessica.gomez@cnag.crg.eu
#Date:20190528

my ($sam);

GetOptions(
           's:s'           => \$sam,
           );

open SAM,"< $sam" || die "cannot open input file $sam";
my $ref;
while (<SAM>){
  chomp;
  next if ($_ =~ m/^@/);
  my @line = split /\t/, $_;
  if ($line[0] =~ m/HS61/){
    my @cigar = split //, $line[5];
    my $cigar_len = scalar @cigar;
    my $i = 0;
    my $l = "";
    my $ref_pos = 1;
    my $res_pos = 1;
    my $aln_pos = 1;
    my $f = 1;
    while ($i < $cigar_len){
      if ($cigar[$i] =~ m/[0-9]/){
        $l = "$l" . $cigar[$i];
       # print "$l\n";
      }
      elsif ($cigar[$i] eq "M"){
        $l = int($l);
        print "Pangenome\t$res_pos\t";
        $res_pos = $res_pos + $l - 1;
        print "$res_pos\t$f\tW\tCP011017.1\t$ref_pos\t";
        $f++;
        $ref_pos = $ref_pos + $l - 1;
        print "$ref_pos\t+\n";
        $res_pos++;
        $ref_pos++;
        $aln_pos = $aln_pos + $l;
        $l = "";
      }
      elsif ($cigar[$i] eq "I"){
        $l = int($l);
        print "Pangenome\t$res_pos\t";
        $res_pos = $res_pos + $l - 1;
        print "$res_pos\t$f\tW\tHS61_plasmid\t$aln_pos\t";
        $f++;
        $aln_pos = $aln_pos + $l - 1;
        print "$aln_pos\t+\n";
        $res_pos++;
        $aln_pos++;
        $l = "";
      }
      elsif ($cigar[$i] eq "D"){
        $l = int($l);
        print "Pangenome\t$res_pos\t";
        $res_pos = $res_pos + $l - 1;
        print "$res_pos\t$f\tW\tCP011017.1\t$ref_pos\t";
        $f++;
        $ref_pos = $ref_pos + $l - 1;
        print "$ref_pos\t+\n";
        $res_pos++;
        $ref_pos++;
        $l = "";

      }
      else {
        print STDERR "!!Unkown cigar string character $cigar[$i]\n"; 
        $l = "";
      }
      $i++;
    }
  }
}
close SAM;
