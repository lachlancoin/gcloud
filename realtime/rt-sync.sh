#!/bin/bash
##THIS SCRIPT MONITORS A LOCAL DIRECTORY FOR NEW FASTQ AND RSYNC
#rt-sync.sh  path_to_fastq  sleep
PROJECT=$(gcloud config get-value project)
UPLOAD_EVENTS=UPLOAD_EVENTS
UPLOAD_BUCKET=Uploads
notif=$(gsutil notification list gs://nano-stream1 | grep $UPLOAD_EVENTS | grep $PROJECT)
echo "notifications:  "$notif
#if [ ! $notif ] ; then
# echo "WARNING: no notifications are set for file uploads";
# exit 1;
#fi

#CHECKING INPUT PARAMETERS
dir=$1  #TARGET DIRECTORY
sleepbase=$2  #HOW LONG TO SLEEP
if [ ! $sleepbase ] || [ ! $dir ] ; then 
	echo "usage:  rt-sync.sh  path_to_fastq dir"
	exit 1;	
fi
lastchar=$(echo $1 | rev | cut -b 1)
if [ $lastchar = '/' ];
then
	echo 'do not include the trailing / in the directory name: '$1
	exit 1
fi



GOOGLE="gs://${PROJECT}/Uploads"
dirname=$(echo $dir  | rev | cut -f 1 -d /  | rev)
targetg=${GOOGLE}/${dirname}
echo "target is "$target
currdir=$(pwd)


timeout=3600   ##TIME TO WAIT FOR NEW FASTQ IN SECONDS BEFORE FINISHING
diff=0
run=0  #starts as zero
while [ "$diff"  -le "$timeout"  ];
do
  sleep=$sleepbase
  if [ "$run" -eq "0" ]; then 
	  a=$(ls $dir | grep fast[aq] | xargs -I {}  stat --printf='%Y\t%n\n' $dir/{}  | sort -k 1,1g  | wc -l )
	   if [ "$a" -ge "2"  ]; then 
		echo "found  files "
		run=1
		sleep=5
	   fi
  else
    sleep=$sleepbase
    lastline=$(ls $dir | grep fast[aq]  | xargs -I {}  stat --printf='%Y\t%n\n' $dir/{}  | sort -k 1,1g  | tail -n 1 )    
    last=$(echo $lastline | cut -f 2 -d ' ')
    lasttime=$(echo $lastline | cut -f 1 -d ' ')
    currtime=$(date +%s) 
    diff=$(($currtime-$lasttime))
    echo "excluding " $last
    echo  "gsutil -m rsync -r -x "$last $dir $targetg
    gsutil -m rsync -r -x $last $dir $targetg
  fi
    echo "sleeping for "${sleep}" seconds"
   sleep $sleep
   echo $diff $timeout
done

finish=1
if [ $finish ] ; then 
#sync remaining
gsutil -m rsync -r $dir $targetg
fi  
