#!/bin/bash

#SBATCH --job-name=fastq_splitting
#SBATCH --output=split.log
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --ntasks-per-node=1
#SBATCH --mem=7800 # mb
#SBATCH --time=100:00:00


##this script takes a fastq file (even a symlink) and converts it into a tar with many fastq. Also works for fasta
##works with fastq or fasta .gz or not
## sh split_fastq.sh Sulfurihydrogenibium_YO3AOP1.fastq.gz   8

file=$1
lines=$2
minlines=16
unit=4
rem=$(($lines % $unit))
if [ "$rem" -gt 0 ]; then
	echo 'chunk size not divisible by  '$unit
	exit 1;
fi
if [ "$lines" -lt "$minlines" ]; then
	echo 'too small chunk size '
	exit 1;
fi
echo $file
len=$(less $file | wc -l )
echo $len
if [ "$len" -gt "$lines" ]; then
	a=$(echo $file  | grep '.gz' | wc -l)
	echo $a
	if [ $a -eq 1 ] ; then
		echo 'here'
		file1=$(echo $file | sed 's/.gz//')
		less $file > $file1
		file=$file1
		echo $file
	fi


	b=$(echo $file  | grep '.fastq' | wc -l)
	if [ $b -eq 1 ] ; then
		suffix=".fastq"
		dir=$(echo $file | sed 's/.fastq//')
	else 
		suffix=".fasta"
		dir=$(echo $file | sed 's/.fasta//')
	fi

	if [ ! -e $dir ]; then 
		mkdir $dir
		cd $dir
		split -l $lines --additional-suffix=$suffix ../$file $dir"."
		ls  | xargs gzip
		cd ..
		tar -cvf $dir.tar  $dir --remove-files
	fi
	##if we have unzipped remove unzipped version 
	if [ $a -eq 1 ] ; then
		rm $file
	fi
fi
