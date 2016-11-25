#!/usr/bin/perl -w
use strict;


my $in1File = $ARGV[0];
my $in2File = $ARGV[1];
my $stlFile = $ARGV[2];
my $stl1List = $ARGV[3];
my $stl2List = $ARGV[4];
my $outFile1 = $ARGV[5];
my $outFile2 = $ARGV[6];


my %stlList = ();

open(FTR,"<$stlFile") or die;


while (my $input = <FTR>) {
    chomp($input);
    
    $stlList{"$input"} = 1;
}


close(FTR);



open(FTR_1,"<$in1File") or die;
open(FTR_2,"<$in2File") or die;
open(FTW_1,">$stl1List") or die;
open(FTW_2,">$stl2List") or die;
open(FTW_3,">$outFile1") or die;
open(FTW_4,">$outFile2") or die;


my %barcodsList_1 = ();
my %barcodsList_2 = ();

my $allCount = 0;
my $stlCount = 0;



while (my $input = <FTR_1>) {
    
    my $strToWrite = "";
    my $isWrite = 0;
    $strToWrite = $strToWrite.$input;
    chomp($input);
    my $seqNam = substr($input,1);
    $input = <FTR_1>;
    my $seqWo9 = substr($input,9);
    $strToWrite = $strToWrite.$seqWo9;
    chomp($input);
    my $first8 = substr($input,0,8);
    
    my $input2 = <FTR_2>;
    my $strToWrite2 = "";
    $strToWrite2 = $strToWrite2.$input2;
    chomp($input2);
    my $seqNam2 = substr($input2,1);
    $input2 = <FTR_2>;
    my $seqWo9_2 = substr($input2,9);
    $strToWrite2 = $strToWrite2.$seqWo9_2;
    chomp($input2);
    my $first8_2 = substr($input2,0,8);
    
    if ((exists $stlList{"$first8"}) && (exists $stlList{"$first8_2"})) {
	$stlCount++;
	$isWrite = 1;
	if (exists $barcodsList_1{"$first8"}) {
	    my $ptrArrSeqNams = $barcodsList_1{"$first8"};
	    push @$ptrArrSeqNams,$seqNam;
	    
	}
	else
	{
	    my @arrSeqNams = ();
	    push @arrSeqNams,$seqNam;
	    $barcodsList_1{"$first8"} = \@arrSeqNams;
	}
	
	if (exists $barcodsList_2{"$first8_2"}) {
	    my $ptrArrSeqNams = $barcodsList_2{"$first8_2"};
	    push @$ptrArrSeqNams,$seqNam2;
	    
	}
	else
	{
	    my @arrSeqNams = ();
	    push @arrSeqNams,$seqNam2;
	    $barcodsList_2{"$first8_2"} = \@arrSeqNams;
	}
    }
    
    
    
    
    $input = <FTR_1>;
    $strToWrite = $strToWrite.$input;
    $input = <FTR_1>;
    my $qualWo9 = substr($input,9);
    $strToWrite = $strToWrite.$qualWo9;
    
    if ($isWrite == 1) {
	print FTW_3 "$strToWrite";
    }
    
    
    $input2 = <FTR_2>;
    $strToWrite2 = $strToWrite2.$input2;
    $input2 = <FTR_2>;
    my $qualWo9_2 = substr($input2,9);
    $strToWrite2 = $strToWrite2.$qualWo9_2;
    
    if ($isWrite == 1) {
	print FTW_4 "$strToWrite2";
    }
    
    
    $allCount++;
}


my @barcodsArr = keys %stlList;

for(my $i = 0;$i <= $#barcodsArr;$i++)
{
    my $currBarcod = $barcodsArr[$i];
    my $ptrArrSeqNams_1 = $barcodsList_1{"$currBarcod"};
    
    for(my $j = 0;$j <=$#$ptrArrSeqNams_1;$j++)
    {
	my $currSeqNam = $ptrArrSeqNams_1->[$j];
	print FTW_1 "$currBarcod\t$currSeqNam\n";
    }
    my $ptrArrSeqNams_2 = $barcodsList_2{"$currBarcod"};
    
    for(my $j = 0;$j <=$#$ptrArrSeqNams_2;$j++)
    {
	my $currSeqNam = $ptrArrSeqNams_2->[$j];
	print FTW_2 "$currBarcod\t$currSeqNam\n";
    }
    
}



print "$allCount\t$stlCount\n";



close(FTR_1);
close(FTR_2);
close(FTW_1);
close(FTW_2);
close(FTW_3);
close(FTW_4);



