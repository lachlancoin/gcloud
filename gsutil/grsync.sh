#run example
# sh grsync.sh /DataOnline/Data/Projects/GCP/test1/20180326_EDTABloodcollection/20180326_spiked/ gs://nano-stream1/Uploads/Tanzania
currdir=$(pwd)
dir=$1
target=$2
sleep=5
timeout=$(($sleep*10))
diff=0
run=0  #starts as zero
while [ "$diff"  -le "$timeout"  ];
do
  if [ "$run" -eq "0" ]; then 
	  a=$(find "$dir" -name *.fast[aq] | xargs -I {}  stat --printf='%Y\t%n\n' {}  | sort -k 1,1g  | wc -l )
	   if [ "$a" -ge "2"  ]
		run=1
	   fi
  else
   lastline=$(find "$dir" -name *.fast[aq] | xargs -I {}  stat --printf='%Y\t%n\n' {}  | sort -k 1,1g  | tail -n 1 )    
    last=$(echo $lastline | cut -f 2 -d ' ')
    lasttime=$(echo $lastline | cut -f 1 -d ' ')
    currtime=$(date +%s) 
    diff=$(($currtime-$lasttime))
    #gsutil rsync -n $dir $target
    gsutil -m rsync -r -x $last $dir $target
  fi
  sleep $sleep
  echo 'sleeping for {$sleep} seconds'
done
 gsutil -m rsync -r $dir $target
