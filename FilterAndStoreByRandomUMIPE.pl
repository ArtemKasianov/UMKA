#!/usr/bin/perl -w
use strict;


my $in1File = $ARGV[0];
my $in2File = $ARGV[1];
my $lengthOfUMI = $ARGV[2];
my $minUMICount = $ARGV[3];
my $stl1List = $ARGV[4];
my $stl2List = $ARGV[5];
my $outFile1 = $ARGV[6];
my $outFile2 = $ARGV[7];


my %umiList = ();
my %umiTmpList = ();






open(FTR_1,"<$in1File") or die;
open(FTR_2,"<$in2File") or die;
open(FTW_1,">$stl1List") or die;
open(FTW_2,">$stl2List") or die;
open(FTW_3,">$outFile1") or die;
open(FTW_4,">$outFile2") or die;


my %barcodsList_1 = ();
my %barcodsList_2 = ();

my $allCount = 0;
my $umiCount = 0;

while (my $input = <FTR_1>) {
    chomp($input);
    $input = <FTR_1>;
    my $currUMI = substr($input,0,$lengthOfUMI);
    if (exists $umiTmpList{"$currUMI"}) {
	$umiTmpList{"$currUMI"} = $umiTmpList{"$currUMI"} + 1;
    }
    else
    {
	$umiTmpList{"$currUMI"} = 1;
    }
    
    $input = <FTR_1>;
    $input = <FTR_1>;
}

while (my $input = <FTR_2>) {
    chomp($input);
    $input = <FTR_2>;
    my $currUMI = substr($input,0,$lengthOfUMI);
    if (exists $umiTmpList{"$currUMI"}) {
	$umiTmpList{"$currUMI"} = $umiTmpList{"$currUMI"} + 1;
    }
    else
    {
	$umiTmpList{"$currUMI"} = 1;
    }
    
    $input = <FTR_2>;
    $input = <FTR_2>;
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


seek(FTR_1,0,0);
seek(FTR_2,0,0);

while (my $input = <FTR_1>) {
    
    my $strToWrite = "";
    my $isWrite = 0;
    $strToWrite = $strToWrite.$input;
    chomp($input);
    my $seqNam = substr($input,1);
    $input = <FTR_1>;
    my $seqWoUMI = substr($input,$lengthOfUMI);
    $strToWrite = $strToWrite.$seqWoUMI;
    chomp($input);
    my $firstUMI = substr($input,0,$lengthOfUMI);
    
    my $input2 = <FTR_2>;
    my $strToWrite2 = "";
    $strToWrite2 = $strToWrite2.$input2;
    chomp($input2);
    my $seqNam2 = substr($input2,1);
    $input2 = <FTR_2>;
    my $seqWoUMI_2 = substr($input2,$lengthOfUMI);
    $strToWrite2 = $strToWrite2.$seqWoUMI_2;
    chomp($input2);
    my $firstUMI_2 = substr($input2,0,$lengthOfUMI);
    
    if ((exists $umiList{"$firstUMI"}) && (exists $umiList{"$firstUMI_2"})) {
	$umiCount++;
	$isWrite = 1;
	if (exists $barcodsList_1{"$firstUMI"}) {
	    my $ptrArrSeqNams = $barcodsList_1{"$firstUMI"};
	    push @$ptrArrSeqNams,$seqNam;
	    
	}
	else
	{
	    my @arrSeqNams = ();
	    push @arrSeqNams,$seqNam;
	    $barcodsList_1{"$firstUMI"} = \@arrSeqNams;
	}
	
	if (exists $barcodsList_2{"$firstUMI_2"}) {
	    my $ptrArrSeqNams = $barcodsList_2{"$firstUMI_2"};
	    push @$ptrArrSeqNams,$seqNam2;
	    
	}
	else
	{
	    my @arrSeqNams = ();
	    push @arrSeqNams,$seqNam2;
	    $barcodsList_2{"$firstUMI_2"} = \@arrSeqNams;
	}
    }
    
    
    
    
    $input = <FTR_1>;
    $strToWrite = $strToWrite.$input;
    $input = <FTR_1>;
    my $qualWoUMI = substr($input,$lengthOfUMI);
    $strToWrite = $strToWrite.$qualWoUMI;
    
    if ($isWrite == 1) {
	print FTW_3 "$strToWrite";
    }
    
    
    $input2 = <FTR_2>;
    $strToWrite2 = $strToWrite2.$input2;
    $input2 = <FTR_2>;
    my $qualWoUMI_2 = substr($input2,$lengthOfUMI);
    $strToWrite2 = $strToWrite2.$qualWoUMI_2;
    
    if ($isWrite == 1) {
	print FTW_4 "$strToWrite2";
    }
    
    
    $allCount++;
}


my @barcodsArr = keys %umiList;

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



print "$allCount\t$umiCount\n";



close(FTR_1);
close(FTR_2);
close(FTW_1);
close(FTW_2);
close(FTW_3);
close(FTW_4);



