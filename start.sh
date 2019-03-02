#!/bin/bash

#Manual steps:


#1. Set up firestore as part of gcloud account setup
#2. create storage bucket  Uploads/
#3. Set up UPLOAD_EVENTS topic at https://console.cloud.google.com/cloudpubsub/topicList?project=nano-stream1
#4 . Log into cloud shell from https://console.cloud.google.com
#5. 

export ALIGNER_REGION="asia-northeast1"
PROJECT=$(gcloud config get-value project)




## GET HELPER SCRIPTS
if [ ! -e "./gcloud" ]; then
	git clone "https://github.com/lachlancoin/gcloud.git"
else 
	cd ./gcloud/
	git pull
	cd ..
fi


##SET UP NOTIFICATIONS AND SUBSCRIPTIONS
source ./gcloud/pubsub/delete_all_notifications.sh
source ./gcloud/pubsub/make_notifications.sh 


##check out the source for nanostream-dataflow
if [ ! -e "./nanostream-dataflow" ]; then
	git clone "https://github.com/allenday/nanostream-dataflow.git"
else
	cd ./nanostream-dataflow/
	git pull ## get latest version
	if [ -e "./NanostreamDataflowMain/target/NanostreamDataflowMain-1.0-SNAPSHOT.jar" ]; then
		rm ./NanostreamDataflowMain/target/NanostreamDataflowMain-1.0-SNAPSHOT.jar
	fi
	cd ..
fi







##build jar /NanostreamDataflowMain/target/NanostreamDataflowMain-1.0-SNAPSHOT.jar
if [ ! -e './nanostream-dataflow/NanostreamDataflowMain/target/NanostreamDataflowMain-1.0-SNAPSHOT.jar' ]; then
	if [ ! -e './nanostream-dataflow/NanostreamDataflowMain/libs/japsa.jar' ]; then
		echo 'cannot find ./NanostreamDataflowMain/libs/japsa.jar'
		exit 1
	fi
	cd ./nanostream-dataflow/
	mvn install:install-file -Dfile=NanostreamDataflowMain/libs/japsa.jar -DgroupId=coin -DartifactId=japsa -Dversion=1.9-3c -Dpackaging=jar
	mvn install:install-file -Dfile=NanostreamDataflowMain/libs/pal1.5.1.1.jar -DgroupId=nz.ac.auckland -DartifactId=pal -Dversion=1.5.1.1 -Dpackaging=jar
	cd NanostreamDataflowMain
	mvn clean package
	if [ ! -e './target/NanostreamDataflowMain-1.0-SNAPSHOT.jar' ]; then
	  echo 'not successfully built'
	  exit 1;
	if
	cd ../..  #back to top level
fi

##PROVISION aligner cluster
provisioned=$(gcloud compute forwarding-rules describe bwa-species-forward --region=${ALIGNER_REGION} --format="value(IPAddress)" | grep 'loadBalancing')
if [ ! $provisioned ]; then 
	cd ./gcloud/aligner
	bash ./provision_species_bwa.sh
	cd ../../
fi

SLEEP=60
while [ ! $provisioned ]; do
	provisioned=$(gcloud compute forwarding-rules describe bwa-species-forward --region=${ALIGNER_REGION} --format="value(IPAddress)" | grep 'loadBalancing')
	echo "sleeping ${SLEEP} while waiting for alignment cluster";
	sleep $SLEEP
done

echo "starting dataflow"
bash ./gcloud/dataflow/start_dataflow.sh 

echo "Should be good to go (modulo any errors from previous steps).  You can now us gsutil cp or gustil rsync to copy files to gs://${PROJECT}/Uploads directory";
echo "once finished make sure you shutdown aligner cluster with end.sh script"






