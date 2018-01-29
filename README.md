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
specify size when trimming....ditch really short reads.
Map to ref via gsnap
call/phase via freebayes
parse AN per gene and group by chromosome of origin
