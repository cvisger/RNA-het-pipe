#!/bin/bash
conda config --add channels r
conda config --add channels defaults
conda config --add channels conda-forge
conda config --add channels bioconda
conda install -c bioconda sra-tools -y
conda install fastqc -y
conda install trimmomatic -y
conda install freebayes -y
conda install -c bioconda gmap -y
conda install -c bioconda samtools -y
conda install -c bioconda snpeff -y
