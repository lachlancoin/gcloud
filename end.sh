#!/bin/bash

if [ ! $ALIGNER_REGION ]; then
	echo "please define global parameter ALIGNER_REGION using e.g. export ALIGNER_REGION=\"asia-northeast1\""
	exit 1;
fi
gcloud dataflow jobs list | grep Running | cut -f 1 -d ' ' | xargs -I {} gcloud dataflow jobs --project=nano-stream1 cancel --region=$ALIGNER_REGION {}
cd ./gcloud/aligner
bash ./provision_species_bwa.sh -c



