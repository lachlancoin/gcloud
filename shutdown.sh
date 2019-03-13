#!/bin/bash
##optionally can specify the run parameters
PROJECT=$(gcloud config get-value project)


CLOUDSHELL=$(hostname | grep '^cs' | wc -l )
echo "CLOUDSHELL "$cloudshell



OPTION=$1 
export RESNAME=$2
if [ ! $1 ] || [ ! $2 ]; then
	 echo "usage bash shutdown.sh|bwa-species|mm2-species|bwa-resistance|mm2-resistance  res_prefix"
	 exit 1
else
	paramsfile="parameters/params-${OPTION}-${RESNAME}"
fi 


cd $HOME
if [ -e "./github" ]; then cd github ; fi
mkdir -p parameters
#gsutil rsync -d parameters gs://$PROJECT/parameters
gsutil cp  gs://$PROJECT/${paramsfile} ${paramsfile}


if [ ! -e $paramsfile ] ; then
	echo  "${paramsfile} does not exist"
	exit 1;
fi

source $paramsfile


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


dinfo=$(stat --printf='%Y\t%n\n' $paramsfile | cut -f 1)
mv $paramsfile $paramsfile.${dinfo}
gsutil cp  ${paramsfile}.${dinfo} gs://$PROJECT/$paramsfile.${dinfo}
gsutil rm  gs://$PROJECT/${paramsfile} 
#gsutil rsync -d parameters gs://$PROJECT/parameters

