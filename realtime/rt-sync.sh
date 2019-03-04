#!/bin/bash
##THIS SCRIPT MONITORS A LOCAL DIRECTORY FOR NEW FASTQ AND RSYNC
#bash ./gcloud/rt-sync.sh  path_to_fastq UPLOAD_BUCKET_ON_CLOUD

dir=$1  #TARGET DIRECTORY
PROJECT=$(gcloud config get-value project)

sleepbase=60  #HOW LONG TO SLEEP BETWEEN CHECKING

#GETS THE CURRENT RUNNING PARAMETERS
gsutil rsync  gs://$PROJECT/parameters parameters
source parameters/params


bucket=$(gsutil ls gs://${PROJECT} | grep "${PROJECT}/${UPLOAD_BUCKET}")
if [ ! $bucket ]; then 
	echo "could not find ${PROJECT}/${UPLOAD_BUCKET}";
	exit 1;
fi

notif=$(gsutil notification list ${PROJECT} | grep $UPLOAD_EVENTS | grep $PROJECT)
subscriptions=$(gcloud pubsub subscriptions list | grep $UPLOAD_EVENTS )
echo "notifications:  "$notif
echo "subscriptoins:  "$subscriptions

if [ ! $notif ] || [ ! $subscriptions ]  ; then
 echo "Need to have subscriptions and notifications set"
 exit 1
fi

#CHECKING INPUT PARAMETERS
if  [ ! $dir ] || [ ! $UPLOAD_BUCKET ]; then 
	echo "usage:  rt-sync.sh  path_to_fastq"
	exit 1;	
fi
lastchar=$(echo $1 | rev | cut -b 1)
if [ $lastchar = '/' ];
then
	echo 'do not include the trailing / in the directory name: '$1
	exit 1
fi



GOOGLE="gs://${PROJECT}/{$UPLOAD_BUCKET}"
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
