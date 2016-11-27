#!/usr/bin/perl -w
use strict;


my $inFile = $ARGV[0];
my $lengthOfUMI = $ARGV[1];
my $minUMICount = $ARGV[2];
my $stlList = $ARGV[3];
my $outFile = $ARGV[4];


my %umiList = ();
my %umiTmpList = ();



open(FTR,"<$inFile") or die;
open(FTW,">$stlList") or die;
open(FTW_1,">$outFile") or die;


my %barcodsList = ();

my $allCount = 0;
my $umiCount = 0;

while (my $input = <FTR>) {
    chomp($input);
    $input = <FTR>;
    my $currUMI = substr($input,0,$lengthOfUMI);
    if (exists $umiTmpList{"$currUMI"}) {
	$umiTmpList{"$currUMI"} = $umiTmpList{"$currUMI"} + 1;
    }
    else
    {
	$umiTmpList{"$currUMI"} = 1;
    }
    
    $input = <FTR>;
    $input = <FTR>;
}


my @arrUMI = keys %umiTmpList;
for(my $i = 0;$i <= $#arrUMI; $i++)
{
    my $currUMI = $arrUMI[$i];
    if (not exists $umiTmpList{"$currUMI"}) {
	die;
    }
    if ($umiTmpList{"$currUMI"} > $minUMICount) {
	$umiList{"$currUMI"} = 1;
    }
    
    
}


seek(FTR,0,0);

while (my $input = <FTR>) {
    
    my $strToWrite = "";
    my $isWrite = 0;
    $strToWrite = $strToWrite.$input;
    chomp($input);
    my $seqNam = substr($input,1);
    $input = <FTR>;
    my $seqWoSTL = substr($input,$lengthOfUMI);
    $strToWrite = $strToWrite.$seqWoSTL;
    chomp($input);
    my $umiString = substr($input,0,$lengthOfUMI);
    
    if (exists $umiList{"$umiString"}) {
	$umiCount++;
	$isWrite = 1;
	if (exists $barcodsList{"$umiString"}) {
	    my $ptrArrSeqNams = $barcodsList{"$umiString"};
	    push @$ptrArrSeqNams,$seqNam;
	    
	}
	else
	{
	    my @arrSeqNams = ();
	    push @arrSeqNams,$seqNam;
	    $barcodsList{"$umiString"} = \@arrSeqNams;
	}
    }
    
    
    
    
    $input = <FTR>;
    $strToWrite = $strToWrite.$input;
    $input = <FTR>;
    my $qualStr = substr($input,$lengthOfUMI);
    $strToWrite = $strToWrite.$qualStr;
    
    if ($isWrite == 1) {
	print FTW_1 "$strToWrite";
    }
    
    
    $allCount++;
}


my @barcodsArr = keys %umiList;

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



print "$allCount\t$umiCount\n";



close(FTR);
close(FTW);
close(FTW_1);



