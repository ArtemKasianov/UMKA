#!/usr/bin/perl -w
use strict;


my $inFile = $ARGV[0];
my $stlFile = $ARGV[1];
my $stlList = $ARGV[2];
my $outFile = $ARGV[3];


my %stlList = ();

open(FTR,"<$stlFile") or die;


while (my $input = <FTR>) {
    chomp($input);
    
    $stlList{"$input"} = 1;
}


close(FTR);



open(FTR,"<$inFile") or die;
open(FTW,">$stlList") or die;
open(FTW_1,">$outFile") or die;


my %barcodsList = ();

my $allCount = 0;
my $stlCount = 0;



while (my $input = <FTR>) {
    
    my $strToWrite = "";
    my $isWrite = 0;
    $strToWrite = $strToWrite.$input;
    chomp($input);
    my $seqNam = substr($input,1);
    $input = <FTR>;
    my $seqWo9 = substr($input,9);
    $strToWrite = $strToWrite.$seqWo9;
    chomp($input);
    my $first8 = substr($input,0,8);
    
    if (exists $stlList{"$first8"}) {
	$stlCount++;
	$isWrite = 1;
	if (exists $barcodsList{"$first8"}) {
	    my $ptrArrSeqNams = $barcodsList{"$first8"};
	    push @$ptrArrSeqNams,$seqNam;
	    
	}
	else
	{
	    my @arrSeqNams = ();
	    push @arrSeqNams,$seqNam;
	    $barcodsList{"$first8"} = \@arrSeqNams;
	}
    }
    
    
    
    
    $input = <FTR>;
    $strToWrite = $strToWrite.$input;
    $input = <FTR>;
    my $qualWo9 = substr($input,9);
    $strToWrite = $strToWrite.$qualWo9;
    
    if ($isWrite == 1) {
	print FTW_1 "$strToWrite";
    }
    
    
    $allCount++;
}


my @barcodsArr = keys %stlList;

for(my $i = 0;$i <= $#barcodsArr;$i++)
{
    my $currBarcod = $barcodsArr[$i];
    my $ptrArrSeqNams = $barcodsList{"$currBarcod"};
    
    for(my $j = 0;$j <=$#$ptrArrSeqNams;$j++)
    {
	my $currSeqNam = $ptrArrSeqNams->[$j];
	print FTW "$currBarcod\t$currSeqNam\n";
    }
    
}



print "$allCount\t$stlCount\n";



close(FTR);
close(FTW);
close(FTW_1);



