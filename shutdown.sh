#!/bin/bash
##optionally can specify the run parameters
PROJECT=$(gcloud config get-value project)


CLOUDSHELL=$(hostname | grep '^cs' | wc -l )
echo "CLOUDSHELL "$cloudshell

if [ "$CLOUDSHELL" -ne 1 ]; then
	mkdir -p parameters
	gsutil cp  gs://$PROJECT/parameters/params parameters/params
fi

cd $HOME
if [ -e "./github" ]; then cd github ; fi
if [ $1 ]; then
	source $1
else
	source parameters/params
fi

if [ ! $ALIGNER_REGION ]; then
	echo "please define global parameter ALIGNER_REGION using e.g. export ALIGNER_REGION=\"asia-northeast1\""
	exit 1;
fi

if [ ! $UPLOAD_SUBSCRIPTION ]; then
	echo "please define UPLOAD_SUBSCRIPTION"
	exit 1;
fi
if [ $JOBID ]; then
	gcloud dataflow jobs list | grep ${JOBID}  | cut -f 1 -d ' ' | xargs -I {} gcloud dataflow jobs --project=$PROJECT cancel --region=$ALIGNER_REGION {}
else
	gcloud dataflow jobs list | grep Running | cut -f 1 -d ' ' | xargs -I {} gcloud dataflow jobs --project=$PROJECT cancel --region=$ALIGNER_REGION {}
fi

#DE-COMMISSION ALIGNER
source ./gcloud/aligner/provision_internal.sh
cleanup


#CLOSE SUBSCRIPTION
echo "gcloud pubsub subscriptions list | grep name | grep ${UPLOAD_SUBSCRIPTION} | cut -f 2 -d ' '  | xargs -I {} gcloud pubsub subscriptions delete {}"
gcloud pubsub subscriptions list | grep 'name' | grep ${UPLOAD_SUBSCRIPTION} |  cut -f 2 -d ' '  | xargs -I {} gcloud pubsub subscriptions delete {}

## DELETES ALL NOTIFICATIONS - but no reason to do this, other pipelines could be using it
#source ../pubsub/delete_all_notifications.sh
