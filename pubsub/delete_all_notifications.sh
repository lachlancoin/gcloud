#!/bin/bash
PROJECT=$(gcloud config get-value project)

##DELETE ALL EXISTING NOTIFICATIONS:
	echo "deleting all notifications";
	echo "gcloud pubsub subscriptions list | grep name | cut -f 2 -d ' '  | xargs -I {} gcloud pubsub subscriptions delete {}"
	echo "gsutil notification list ${PROJECT}   | grep  'projects/_/'  | xargs -I {} gsutil notification delete {}"
	gcloud pubsub subscriptions list | grep 'name' | cut -f 2 -d ' '  | xargs -I {} gcloud pubsub subscriptions delete {}
	gsutil notification list gs://$PROJECT   | grep  'projects/_/'  | xargs -I {} gsutil notification delete {}

