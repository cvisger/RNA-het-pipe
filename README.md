# RNA-het-pipe

# AWS ubuntu setup

press enter when prompted and install to default locations
```
wget https://raw.githubusercontent.com/cvisger/RNA-het-pipe/master/setup.sh
wget https://raw.githubusercontent.com/cvisger/RNA-het-pipe/master/apps.sh
chmod +x setup.sh
chmod +x apps.sh
./setup.sh
./apps.sh
#pull just chromosome assemblies  and cat
wget ftp://ftp.ensemblgenomes.org/pub/plants/release-38/fasta/trifolium_pratense/dna/Trifolium_pratense.Trpr.dna.chromosome.LG1.fa.gz
wget ftp://ftp.ensemblgenomes.org/pub/plants/release-38/fasta/trifolium_pratense/dna/Trifolium_pratense.Trpr.dna.chromosome.LG2.fa.gz
wget ftp://ftp.ensemblgenomes.org/pub/plants/release-38/fasta/trifolium_pratense/dna/Trifolium_pratense.Trpr.dna.chromosome.LG3.fa.gz
wget ftp://ftp.ensemblgenomes.org/pub/plants/release-38/fasta/trifolium_pratense/dna/Trifolium_pratense.Trpr.dna.chromosome.LG4.fa.gz
wget ftp://ftp.ensemblgenomes.org/pub/plants/release-38/fasta/trifolium_pratense/dna/Trifolium_pratense.Trpr.dna.chromosome.LG5.fa.gz
wget ftp://ftp.ensemblgenomes.org/pub/plants/release-38/fasta/trifolium_pratense/dna/Trifolium_pratense.Trpr.dna.chromosome.LG6.fa.gz
wget ftp://ftp.ensemblgenomes.org/pub/plants/release-38/fasta/trifolium_pratense/dna/Trifolium_pratense.Trpr.dna.chromosome.LG7.fa.gz
gunzip *LG*.fa.gz
cat *LG*.fa > redclover_ref.fa
```

# test run with one sample 
(can add --gzip option to compress fastq-dump output)

```
fastq-dump ERR1665297
fastqc ERR1665297.fastq
trimmomatic SE ERR1665297.fastq ERR1665297.trimmed.fq SLIDINGWINDOW:4:30
fastqc ERR1665297.trimmed.fq
```
Trim output: Input Reads: 20856487 Surviving: 17829749 (85.49%) Dropped: 3026738 (14.51%)

# TODO
specify size when trimming....ditch really short reads also test just using ILLUMINACLIP TruSeq Adapter and no quality clip
Part-done: added a final MINLEN option and relaxed trimming slightly to phred 20
```
trimmomatic SE ERR1665297.fastq.gz ERR1665297.trimmed.fq.gz SLIDINGWINDOW:4:20 MINLEN:36
fastqc ERR1665297.trimmed.fq.gz
```
Trim output: Input Reads: 20856487 Surviving: 19381820 (92.93%) Dropped: 1474667 (7.07%) 
(see: ERR1665297.trimmed_fastqc_SW_4_20_MINLEN36.html)


## Map to ref via gsnap
Index reference genome (command format:  gmap_build -d <genome> [-k <kmer size>] <fasta_files...>)  
Note: kmer size of 15 will require 4 GB RAM
```
gmap_build -d redclover_ref -k 15 redclover_ref.fa
```

## Map SE reads with default parameters and pipe to samtools
format: gsnap --gunzip -d <genome> --force-single-end <fastq1.gz> [<fastq2.gz>...])  
gsnap should work with genomes up to ~4.3 Gbp (otherwise an error will be thrown asking for gsnap1)  
  ***--gunzip doesn't work on the gsnap install running on aws -- need to gunzip first***  
  added '--gunzip' option to work on .gz files    
  added '--novelsplicing 1' for RNA-seq data  
```
gsnap --gunzip -d redclover_ref --novelsplicing 1 --format sam --read-group-id=ERR1665297 --read-group-library=ERR1665297 --read-group-platform=illumina --force-single-end ERR1665297.trimmed.fq | samtools view -Sbh - | samtools sort -O bam -T 12345 - > ERR1665297_sorted.bam
```

## index BAM
```
samtools index ERR1665297_sorted.bam
```

## output basic stats on BAM
```
samtools stats ERR1665297_sorted.bam > ERR1665297_sorted.stats.txt
```


## call/phase via freebayes (default calls SNPs, indels and multincleotide polymorphisms)

***--left-align-indels isnt a valid command "do we want `--dont-left-align-indels` "   also need ref added in after -f***
freebayes --min-alternate-fraction 0.1 --ploidy 4 --hwe-priors-off --allele-balance-priors-off --max-complex-gap 50 -f redclover_v2.1.fasta ERR1665297_sorted.bam > ERR1665297_to_redclover_ref.vcf
```
freebayes --min-alternate-fraction 0.1 --ploidy 4 --hwe-priors-off --allele-balance-priors-off --max-complex-gap 50 --left-align-indels -f ERR1665297_sorted.bam > ERR1665297_to_redclover_v2.1.vcf
```

## parse AN per gene and group by chromosome of origin
append to out.csv
SRA#,chromosome,geneid,AN
### See VCF and GFF (TxDb) reading-in: https://bioconductor.org/help/workflows/annotation/Annotating_Genomic_Ranges/
### See gene-based VCF variant parsing: https://bioconductor.org/help/workflows/variants/



