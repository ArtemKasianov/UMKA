#!/usr/bin/perl -w
use strict;

my $samFile = $ARGV[0];
my $stl1File = $ARGV[1];
my $stl2File = $ARGV[2];
my $outSamFile = $ARGV[3];



my %stl1List = ();
my %stl2List = ();
my %rNamStl1List = ();
my %rNamStl2List = ();
my @arrPrint = ();
my %readsByCoor = ();
my $allCount = 0;
my $dupReads = 0;


open(FTR,"<$stl1File") or die;


while (my $input = <FTR>) {
    
    chomp($input);
    
    my @arrInp = split(/\t/,$input);
    
    my $barcod = $arrInp[0];
    my $rNam = $arrInp[1];
    
    my @arrRNam = split(/\s+/,$rNam);
    $rNam = $arrRNam[0];
    
    if (not exists $rNamStl1List{"$rNam"}) {
	$rNamStl1List{"$rNam"} = $barcod;

    }
    else
    {
	die;
    }
    
    
    if (exists $stl1List{"$barcod"}) {
	my $ptrRnamList = $stl1List{"$barcod"};
	push @$ptrRnamList,$rNam;
	
    }
    else
    {
	my @arrRnam = ();
	push @arrRnam,$rNam;
	$stl1List{"$barcod"} = \@arrRnam;
    }
    
    
    
}


close(FTR);


open(FTR,"<$stl2File") or die;


while (my $input = <FTR>) {
    
    chomp($input);
    
    my @arrInp = split(/\t/,$input);
    
    my $barcod = $arrInp[0];
    my $rNam = $arrInp[1];
    my @arrRNam = split(/\s+/,$rNam);
    $rNam = $arrRNam[0];
    
    if (not exists $rNamStl2List{"$rNam"}) {
	$rNamStl2List{"$rNam"} = $barcod;

    }
    else
    {
	die;
    }
    
    
    if (exists $stl2List{"$barcod"}) {
	my $ptrRnamList = $stl2List{"$barcod"};
	push @$ptrRnamList,$rNam;
	
    }
    else
    {
	my @arrRnam = ();
	push @arrRnam,$rNam;
	$stl2List{"$barcod"} = \@arrRnam;
    }
}


close(FTR);




my %qNamToPrint = ();
my %qNamCounted = ();
open(FTR,"<$samFile") or die;
my $numLine = -1;

my $numLine_1 = -1;
my $numLine_2 = -1;
while (my $input = <FTR>) {
    chomp($input);
    $numLine++;
    if((substr($input,0,3) eq "\@SQ") || (substr($input,0,3) eq "\@PG") || (substr($input,0,3) eq "\@HD"))
    {
	
	print "$input\n";
	next;
    }
    $allCount++;
    my @arrInp = split(/\t/,$input);
    
    my $qNam = $arrInp[0];
    my $rNam = $arrInp[2];
    my $pos = $arrInp[3];
    my $mateRNam = $arrInp[6];
    if ($mateRNam eq "=") {
	$mateRNam = $rNam;
    }
    my $matePos = $arrInp[7];
    
    my $tempPos = $pos;
    my $tempRNam = $rNam;
    

    
    if ($pos > $matePos) {
	$pos = $matePos;
	$rNam = $mateRNam;
	$matePos = $tempPos;
	$mateRNam = $tempRNam;
    }
    

    
    if((not exists $qNamToPrint{"$qNam"}) && (exists $qNamCounted{"$qNam"}))
    {
	$arrPrint[$numLine] = 0;

	next;
    }

    if ((exists $qNamToPrint{"$qNam"}) && (exists $qNamCounted{"$qNam"})) {
	$arrPrint[$numLine] = 1;
	next;
    }

    $qNamCounted{"$qNam"} = 1;


    
    
    my $qBarcod1 = $rNamStl1List{"$qNam"};
    my $qBarcod2 = $rNamStl2List{"$qNam"};
    
    if(exists $readsByCoor{"$rNam\_$pos\_$mateRNam\_$matePos"})
    {
	
	my $ptrArrReads = $readsByCoor{"$rNam\_$pos\_$mateRNam\_$matePos"};
	my $isFound = 0;
	for(my $i = 0;$i <= $#$ptrArrReads;$i++)
	{
	    my $currRnam = $ptrArrReads->[$i];
	    my $currBarcod1 = $rNamStl1List{"$currRnam"};
	    my $currBarcod2 = $rNamStl2List{"$currRnam"};
	    if (($qBarcod1 eq $currBarcod1) && ($qBarcod2 eq $currBarcod2)) {
		$isFound = 1;
		last;
	    }
	    
	}
	if ($isFound == 0) {
	    push @$ptrArrReads,$qNam;
	    $arrPrint[$numLine] = 1;
	    $qNamToPrint{"$qNam"} = 1;
	}
	else
	{
	    $arrPrint[$numLine] = 0;
	    
	}
    	
    }
    else
    {
	my @arrReads = ();
	push @arrReads,$qNam;
	$readsByCoor{"$rNam\_$pos\_$mateRNam\_$matePos"} = \@arrReads;
	
	
	$arrPrint[$numLine] = 1;
	
	
	
	
	$qNamToPrint{"$qNam"} = 1;
	
    }
    
    
    
    
}

seek(FTR,0,0);



print "Output $numLine_1 $numLine_2\n";
open(FTW,">$outSamFile") or die;
$numLine = -1;
while (my $input = <FTR>) {
    chomp($input);
    $numLine++;
    if(substr($input,0,3) eq "\@SQ")
    {
	print FTW "$input\n";
	next;
    }
    
    if(substr($input,0,3) eq "\@PG")
    {
	print FTW "$input\n";
	next;
    }
    
    if(substr($input,0,3) eq "\@HD")
    {
	print FTW "$input\n";
	next;
    }

    if ($arrPrint[$numLine] == 1) {
    
    
	
	print FTW "$input\n";
    }
    else
    {
	$dupReads++;
    }
    
    
    
    

    
}

close(FTW);
close(FTR);

print "$allCount\t$dupReads\n";
