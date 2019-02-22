#!/bin/bash

#SBATCH --job-name=fastq_splitting
#SBATCH --output=split.log
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --ntasks-per-node=1
#SBATCH --mem=7800 # mb
#SBATCH --time=100:00:00
split_fastq="/home/lcoin/bitbucket/bashscripts/gcloud/split_fastq.sh"
ls | grep ".fast[aq]" > tmp
while read line; do sh ${split_fastq} $line 4000; done < tmp
rm tmp
