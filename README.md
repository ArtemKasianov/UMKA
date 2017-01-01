# UMKA
Set of scripts for reads deduplication by UMI

# How to use
Proceesing of reads organized in two stages:

1) Removing barcodes from reads and storing association of it with reads

- for fixed set of barcodes

 - single - end reads
   FilterAndStoreBySTLSE.pl \<fastq file> \<barcodes list file> \<out stl file> \<out fastq file>
   \<fastq file> - input file with reads to process
   \<barcodes list file> - input file with list of barcodes
   \<out stl file> - output file with asscociation of barcodes and reads
   \<out fastq file> - output file with reads with trimmed barcodes
- paired - end reads
FilterAndStoreBySTLSE.pl <fastq file R1> <fastq file R2> <barcodes list file> <out stl file R1> <out stl file R2> <out fastq file R1> <out fastq file R2>
<fastq file R1>/<fastq file R2> - input files with reads. Mate reads must be separated in different files.
<barcodes list file> - input file with list of barcodes
<out stl file R1>/<out stl file R2> - output files with asscociation of barcodes and reads
<out fastq file R1>/<out fastq file R2> - output file with reads with trimmed barcodes

- for random set of barcodes
- single - end reads
FilterAndStoreBySTLSE.pl <fastq file> <length of barcode> <min count of barcode> <out stl file> <out fastq file>
<fastq file> - input file with reads to process
<length of barcode> - length of read prefix corresponding to barcode
<min count of barcode> - minimum number of reads with barcodes to be considered it reliable
<out stl file> - output file with asscociation of barcodes and reads
<out fastq file> - output file with reads with trimmed barcodes
- paired - end reads
FilterAndStoreBySTLSE.pl <fastq file R1> <fastq file R2> <length of barcode> <min count of barcode> <out stl file R1> <out stl file R2> <out fastq file R1> <out fastq file R2>
<fastq file R1>/<fastq file R2> - input files with reads. Mate reads must be separated in different files.
<length of barcode> - length of read prefix corresponding to barcode
<min count of barcode> - minimum number of reads with barcodes to be considered it reliable
<out stl file R1>/<out stl file R2> - output files with asscociation of barcodes and reads
<out fastq file R1>/<out fastq file R2> - output file with reads with trimmed barcodes


After this stage you need to align reads by some any aligner produces output in SAM format.

2) Deduplicate reads 
- single - end reads
DedupBySTLSE.pl <sam file> <stl file> <out sam file>
<sam file> - input sam file with alignment
<stl file> - input file with with asscociation of barcodes and reads
<out sam file> - output deduplicated sam file 
- paired - end reads
DedupBySTLPE.pl <sam file> <stl file R1> <stl file R2> <out sam file>
<sam file> - input sam file with alignment
<stl file R1>/<stl file R2> - input files with with asscociation of barcodes and reads
<out sam file> - output deduplicated sam file 

To extract deduplicated reads from bam file you can use this scripts:
- single - end reads
GetDedupReadsSE.pl <sam file> <stl file> <out sam file>
<sam file> - input sam file with alignments
<fastq file> - input FASTQ file with reads
<out fastq file> - output FASTQ file with deduplicated reads
- paired - end reads
GetDedupReadsPE.pl <sam file> <fastq file R1> <fastq file R2> <out fastq file R1> <out fastq file R2>
<sam file> - input sam file with alignments
<fastq file R1>/<fastq file R2> - input FASTQ files with reads
<out fastq file R1>/<out fastq file R2> - output FASTQ files with deduplicated reads





