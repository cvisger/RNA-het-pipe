# RNA-het-pipe

#test run

```
fastq-dump ERR1665297
fastqc ERR1665297.fastq
trimmomatic SE ERR1665297.fastq ERR1665297.trimmed.fq SLIDINGWINDOW:4:30
fastqc ERR1665297.trimmed.fq
```
