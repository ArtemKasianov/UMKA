#!/usr/bin/perl -w
use strict;


my $samFile = $ARGV[0];
my $fastq1File = $ARGV[1];
my $out1File = $ARGV[2];


open(FTR,"<$samFile") or die;

my %dedupList = ();

while (my $input = <FTR>) {
    chomp($input);
    next if((substr($input,0,3) eq "\@SQ") || (substr($input,0,3) eq "\@PG") || (substr($input,0,3) eq "\@HD"));

    my @arrInp = split(/\t/,$input);
    
    my $qNam = $arrInp[0];
    my $rNam = $arrInp[2];
    my $pos = $arrInp[3];
    my $mateRNam = $arrInp[6];
    $dedupList{"$qNam"} = 1;
    
}

close(FTR);

open(FTR_1,"<$fastq1File") or die;
open(FTW_1,">$out1File") or die;

while(my $input=<FTR_1>){
    chomp($input);
    my @seqNamArr = split(/\s+/,$input);
    my $seqNam = substr($seqNamArr[0],1);
    if (not exists $dedupList{"$seqNam"}) {
	$input=<FTR_1>;
	$input=<FTR_1>;
	$input=<FTR_1>;
	next;
    }
    
    print FTW_1 "$input\n";
    $input=<FTR_1>;
    print FTW_1 "$input";
    $input=<FTR_1>;
    print FTW_1 "$input";
    $input=<FTR_1>;
    print FTW_1 "$input";
}

close(FTW_1);
close(FTW_2);
close(FTR_1);
close(FTR_2);

