#!/usr/bin/perl -w
use strict;


my $inFile = $ARGV[0];
my $stlFile = $ARGV[1];
my $stlList = $ARGV[2];
my $outFile = $ARGV[3];


my %stlList = ();

open(FTR,"<$stlFile") or die;

my $lengthOfSTL = -1;

while (my $input = <FTR>) {
    chomp($input);
    
    $stlList{"$input"} = 1;
    if ($lengthOfSTL != -1) {
	if ($lengthOfSTL != length($input)) {
	    die("not uniform STL")
	}
	
    }
    else
    {
	$lengthOfSTL = length($input);
    }
    
    
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
    my $seqWoSTL = substr($input,$lengthOfSTL);
    $strToWrite = $strToWrite.$seqWoSTL;
    chomp($input);
    my $stlString = substr($input,0,$lengthOfSTL);
    
    if (exists $stlList{"$stlString"}) {
	$stlCount++;
	$isWrite = 1;
	if (exists $barcodsList{"$stlString"}) {
	    my $ptrArrSeqNams = $barcodsList{"$stlString"};
	    push @$ptrArrSeqNams,$seqNam;
	    
	}
	else
	{
	    my @arrSeqNams = ();
	    push @arrSeqNams,$seqNam;
	    $barcodsList{"$stlString"} = \@arrSeqNams;
	}
    }
    
    
    
    
    $input = <FTR>;
    $strToWrite = $strToWrite.$input;
    $input = <FTR>;
    my $qualStr = substr($input,$lengthOfSTL);
    $strToWrite = $strToWrite.$qualStr;
    
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



