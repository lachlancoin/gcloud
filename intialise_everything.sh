#!/bin/bash

#Manually set up topics on line https://console.cloud.google.com/cloudpubsub/topicList?project=nano-stream1
##NEED TO SETUP UPLOAD_EVENTS TOPIC
##assumes that git is installed and gcloud and gsutil and mvn
##THE FOLLOWING CAN ALL BE RUN IN CLOUD SHELL FROM HOME DIRECTORY

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


##PROVISION aligner cluster
cd ./gcloud/aligner
./provision_species_bwa.sh
cd ../../

SLEEP=60
while [ ! $waiting ]; do
	waiting=$(gcloud compute forwarding-rules describe bwa-species-forward --region=${ALIGNER_REGION} --format="value(IPAddress)" | grep 'Could not fetch')
	echo "sleeping ${SLEEP} while waiting for alignment cluster";
	sleep $SLEEP
done

echo "starting dataflow"
source ./gcloud/dataflow/start_dataflow.sh 

echo "Should be good to go (modulo any errors from previous steps).  You can now us gsutil cp or gustil rsync to copy files to gs://${PROJECT}/Uploads directory";
echo "once finished make sure you shutdown aligner cluster with "








