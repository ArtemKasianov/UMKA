#!/usr/bin/perl -w
use strict;

my $samFile = $ARGV[0];
my $stlFile = $ARGV[1];
my $outSamFile = $ARGV[2];



my %stlList = ();
my %rNamStlList = ();
my @arrPrint = ();
my %readsByCoor = ();
my %cigarByCoor = ();
my $allCount = 0;
my $dupReads = 0;


open(FTR,"<$stlFile") or die;


while (my $input = <FTR>) {
    
    chomp($input);
    
    my @arrInp = split(/\t/,$input);
    
    my $barcod = $arrInp[0];
    my $rNam = $arrInp[1];
    my @arrRNam = split(/\s+/,$rNam);
    $rNam = $arrRNam[0];
    
    if (not exists $rNamStlList{"$rNam"}) {
	$rNamStlList{"$rNam"} = $barcod;
    }
    else
    {
	die("$rNam");
    }
    
    
    if (exists $stlList{"$barcod"}) {
	my $ptrRnamList = $stlList{"$barcod"};
	push @$ptrRnamList,$rNam;
	
    }
    else
    {
	my @arrRnam = ();
	push @arrRnam,$rNam;
	$stlList{"$barcod"} = \@arrRnam;
    }
    
    
    
}


close(FTR);


open(FTR,"<$samFile") or die;
my $numLine = 0;
while (my $input = <FTR>) {
    chomp($input);
    next if((substr($input,0,3) eq "\@SQ") || (substr($input,0,3) eq "\@PG"));
    $allCount++;
    my @arrInp = split(/\t/,$input);
    
    my $qNam = $arrInp[0];
    my $rNam = $arrInp[2];
    my $pos = $arrInp[3];
    my $cigarStr = $arrInp[5];
    my $qBarcod = $rNamStlList{"$qNam"};
    
    if(exists $readsByCoor{"$rNam\_$pos"})
    {
	my $ptrArrReads = $readsByCoor{"$rNam\_$pos"};
	
	my $ptrArrCigar = $cigarByCoor{"$rNam\_$pos"};
	
	
	my $isFound = 0;
	for(my $i = 0;$i <= $#$ptrArrReads;$i++)
	{
	    my $currRnam = $ptrArrReads->[$i];
	    my $currBarcod = $rNamStlList{"$currRnam"};
	    my $currCigar = $ptrArrCigar->[$i];
	    if ($qBarcod eq $currBarcod) {
		if ($currCigar eq $cigarStr) {
		    $isFound = 1;
		}
		
		
	    }
	    
	}
	if ($isFound == 0) {
	    push @$ptrArrReads,$qNam;
	    push @$ptrArrCigar,$cigarStr;
	    $arrPrint[$numLine] = 1;
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
	$readsByCoor{"$rNam\_$pos"} = \@arrReads;
	$arrPrint[$numLine] = 1;
	my @arrCigars = ();
	push @arrCigars,$cigarStr;
	$cigarByCoor{"$rNam\_$pos"} = \@arrCigars;
	
    }
    
    $numLine++;
    
    
}

seek(FTR,0,0);

open(FTW,">$outSamFile") or die;
$numLine = 0;
while (my $input = <FTR>) {
    chomp($input);
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
    
    if ($arrPrint[$numLine] == 1) {
	print FTW "$input\n";
    }
    else
    {
	$dupReads++;
    }
    
    
    
    
    $numLine++;
    
}

close(FTW);
close(FTR);

print "$allCount\t$dupReads\n";
