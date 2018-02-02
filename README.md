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
#pull ref
wget https://zenodo.org/record/17232/files/redclover_v2.1.fasta
wget https://zenodo.org/record/17232/files/redclover_v2.1.gff3
```

# test run with one sample

```
fastq-dump ERR1665297
fastqc ERR1665297.fastq
trimmomatic SE ERR1665297.fastq ERR1665297.trimmed.fq SLIDINGWINDOW:4:30
fastqc ERR1665297.trimmed.fq
```
Trim output: Input Reads: 20856487 Surviving: 17829749 (85.49%) Dropped: 3026738 (14.51%)

# TODO
specify size when trimming....ditch really short reads also test just using ILLUMINACLIP TruSeq Adapter and no quality clip

## Compress trimmed reads
```
gzip ERR1665297.trimmed.fq
```

## Map to ref via gsnap
Index reference genome (command format:  gmap_build -d <genome> [-k <kmer size>] <fasta_files...>)  
Note: kmer size of 15 will require 4 GB RAM
```
gmap_build -d redclover_v2.1 -k 15 redclover_v2.1.fasta
```

## Map SE reads with default parameters and pipe to samtools
format: gsnap --gunzip -d <genome> --force-single-end <fastq1.gz> [<fastq2.gz>...])  
gsnap should work with genomes up to ~4.3 Gbp (otherwise an error will be thrown asking for gsnap1)
```
gsnap --gunzip -d redclover_v2.1 --format sam --read-group-id=ERR1665297 --read-group-library=ERR1665297 --read-group-platform=illumina --force-single-end ERR1665297.trimmed.fq.gz | samtools view -Sbh - | samtools sort -O bam -T 12345 - > ERR1665297_sorted.bam
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
```
freebayes --no-indels --min-alternate-fraction 0.1 --ploidy 4 --hwe-priors-off --allele-balance-priors-off --max-complex-gap 50 --left-align-indels -f ERR1665297_sorted.bam > ERR1665297_to_redclover_v2.1.vcf
```

## parse AN per gene and group by chromosome of origin




