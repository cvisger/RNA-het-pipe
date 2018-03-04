#!/bin/bash

#bash script to print off haplotype counts from VCF 
# usage: bash VCF_pent_allele_count.sh INPUT.vcf 


input_file="${1}"
declare -a LG_list=(LG1 LG2 LG3 LG4 LG5 LG6 LG7) 

for LG in "${LG_list[@]}"
do
	echo -n "Total number of penta-allelic 0/1/2/3/4 sites on Scaffold "$LG":"
	grep $LG  $input_file | grep '0/1/2/3/4'| wc -l
	grep $LG  $input_file | grep '0/1/2/3/4'| awk -v OFS='\t' '{print $2, }'
done

for LG in "${LG_list[@]}"
do
	echo -n "Total number of penta-allelic 1/2/3/4/5 sites on Scaffold "$LG":"
	grep $LG  $input_file | grep '1/2/3/4/5'| wc -l
	grep $LG  $input_file | grep '1/2/3/4/5'| awk -v OFS='\t' '{print $2, }'
done

exit 0
