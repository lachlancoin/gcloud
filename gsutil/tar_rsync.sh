#!/bin/bash

#SBATCH --job-name=rsync_tar
#SBATCH --output=rsync_tar.log
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --ntasks-per-node=1
#SBATCH --mem=7800 # mb
#SBATCH --time=100:00:00


#1 should be a tar directory
#2 is target directory like "gs://nano-stream1//test/"  . It should be the full name of the directory which 
# will contain the reads


b=$(echo $1  | grep '.tar' | wc -l)
if [ $b -eq 0 ] ; then
	echo "not a tar file"
	exit 1;
fi
dir=$(echo $1 | sed 's/.tar//')
tar -xvf $1
gsutil -m rsync $dir $2
tar -cvf $1  $dir --remove-files

