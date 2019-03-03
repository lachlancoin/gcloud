#!/bin/bash

if [ ! $ALIGNER_REGION ]; then
	echo "please define global parameter ALIGNER_REGION using e.g. export ALIGNER_REGION=\"asia-northeast1\""
	exit 1;
fi
if [ ! $PROVISION_SCRIPT ]; then
	echo "please define PROVISION_SCRIPT"
	exit 1;
fi

if [ ! $UPLOAD_SUBSCRIPTION ]; then
	echo "please define UPLOAD_SUBSCRIPTION"
	exit 1;
fi

gcloud dataflow jobs list | grep Running | cut -f 1 -d ' ' | xargs -I {} gcloud dataflow jobs --project=nano-stream1 cancel --region=$ALIGNER_REGION {}
cd ./gcloud/aligner
bash ./${PROVISION_SCRIPT} -c

#CLOSE SUBSCRIPTION
echo "gcloud pubsub subscriptions list | grep name | grep ${UPLOAD_SUBSCRIPTION} | cut -f 2 -d ' '  | xargs -I {} gcloud pubsub subscriptions delete {}"
gcloud pubsub subscriptions list | grep 'name' | grep ${UPLOAD_SUBSCRIPTION} |  cut -f 2 -d ' '  | xargs -I {} gcloud pubsub subscriptions delete {}

## DELETES ALL NOTIFICATIONS - but no reason to do this, other pipelines could be using it
#source ../pubsub/delete_all_notifications.sh
