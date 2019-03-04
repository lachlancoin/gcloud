#!/bin/bash
PROJECT=$(gcloud config get-value project)
##DELETE RELEVANT NOTIFICATION
echo "deleting  notifications";
##SHOULD PROBABLY NEVER NEED TO DO THIS
if [ $UPLOAD_EVENTS ] ; then
	gsutil notification list gs://$PROJECT > tmpfile.txt
	prevline="";
	while read line; do 
	 mtch=$(echo $line | grep "${UPLOAD_EVENTS}" | wc -l  )
	 if [ "$mtch" -eq 1 ]; then
		torev=$(echo $prevline | cut -f 2 -d ' ')
		echo "gsutil notification delete ${torev}"
		gsutil notification delete $torev
	 fi
	 prevline=$line
	done < tmpfile.txt
	rm tmpfile.txt

else
	gsutil notification list gs://$PROJECT | grep  'projects/_/'  | xargs -I {} gsutil notification delete {}

fi

#ALSO DELETE SUBSCRIPTIONS
if [ $UPLOAD_SUBSCRIPTIONS ]; then
gcloud pubsub subscriptions list | grep 'name' | grep ${UPLOAD_SUBSCRIPTION} |  cut -f 2 -d ' '  | xargs -I {} gcloud pubsub subscriptions delete {}
else
gcloud pubsub subscriptions list | grep 'name'  |  cut -f 2 -d ' '  | xargs -I {} gcloud pubsub subscriptions delete {}
fi
