#!/bin/bash
export ALIGNER_REGION="asia-northeast1"
PROJECT=$(gcloud config get-value project)
##document name for results
export RESULTS_PREFIX=$(date '+%Y%m%d%H%m')
export UPLOAD_BUCKET="Uploads"; 
export UPLOAD_EVENTS="UPLOAD_EVENTS"

#Manual steps:
#1. Set up firestore as part of gcloud account setup
#2. Create storage bucket  $UPLOAD_BUCKET
#3. Set up UPLOAD_EVENTS topic at https://console.cloud.google.com/cloudpubsub/topicList?project=nano-stream1
#4 . Log into cloud shell from https://console.cloud.google.com
#5. On cloud shell run  git clone https://github.com/lachlancoin/gcloud.git
#6. On cloud she run  bash ./gcloud/start.sh bwa_species
#7. From local computer Run:  bash ./gcloud/realtime/rt-sync.sh  local_path_to_fastq $UPLOAD_BUCKET
#8. When finished run bash ./gcloud/shutdown.sh

OPTION=$1  
case $OPTION in
        'bwa-species') 
		  SCRIPT="provision_species_bwa.sh";
	 	  SUBSCRIPTION="dataflow_species"
            ;;
        'mm2-species') 
	  	SCRIPT="provision_species_mm2.sh";
	 	SUBSCRIPTION="dataflow_species_mm2"
            ;;
        'bwa-resistance')  
	   	SCRIPT="provision_resistance_bwa.sh";
	   	SUBSCRIPTION="dataflow_resistance "
            ;;
        'mm2-resistance')  
 		SCRIPT="provision_resistance_mm2.sh";
	        SUBSCRIPTION="dataflow_resistance_mm2 "
            ;;
	 \?) #unrecognized option 
          	 echo "not recognised"
	  	 exit 1;
            ;;
esac

export UPLOAD_SUBSCRIPTION="projects/nano-stream1/subscriptions/${SUBSCRIPTION}"
export PROVISION_SCRIPT=$SCRIPT
echo "provisioning script is ${PROVISION_SCRIPT}";
forward=$(grep "export NAME=" ./gcloud/aligner/$PROVISION_SCRIPT | cut -f 2 -d '=' | sed 's/"//g' )
if [ ! $forward ]; then 
echo "could not identify forwarder";
exit 1;
fi

export FORWARDER="${NAME}-forward";

#CHECK EVERYTHING SET UP ON CLOUD:
bucket=$(gsutil ls gs://${PROJECT} | grep "${PROJECT}/${UPLOAD_BUCKET}/")
if [ ! $bucket ]; then 
	echo "could not find ${PROJECT}/${UPLOAD_BUCKET}";
	exit 1;
fi

## GET/UPDATE HELPER SCRIPTS
if [ ! -e "./gcloud" ]; then
	git clone "https://github.com/lachlancoin/gcloud.git"
else 
	cd ./gcloud/
	git pull
	cd ..
fi


##SET UP NOTIFICATIONS AND SUBSCRIPTIONS
source ./gcloud/pubsub/make_notifications.sh 


##check out the source for nanostream-dataflow
if [ ! -e "./nanostream-dataflow" ]; then
	git clone "https://github.com/allenday/nanostream-dataflow.git"
else
	cd ./nanostream-dataflow/
	uptodate=$(git pull | grep 'up-to-date' | wc -l) ## get latest version
	if [ "$uptodate" -eq 0 ] && [ -e "./NanostreamDataflowMain/target/NanostreamDataflowMain-1.0-SNAPSHOT.jar" ]; then
		rm ./NanostreamDataflowMain/target/NanostreamDataflowMain-1.0-SNAPSHOT.jar
	fi
	cd ..
fi

##build jar /NanostreamDataflowMain/target/NanostreamDataflowMain-1.0-SNAPSHOT.jar if it doesnt exist
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
provisioned=$(gcloud compute forwarding-rules describe ${FORWARDER}--region=${ALIGNER_REGION} --format="value(IPAddress)" | grep 'loadBalancing')
if [ ! $provisioned ]; then 
	cd ./gcloud/aligner
	bash ./${PROVISION_SCRIPT}
	cd ../../
fi

if [ ! $NAME ] ;
	echo "NAME was not defined";
	exit 1
fi



SLEEP=60
while [ ! $provisioned ]; do
	provisioned=$(gcloud compute forwarding-rules describe bwa-species-forward --region=${ALIGNER_REGION} --format="value(IPAddress)" | grep 'loadBalancing')
	echo "sleeping ${SLEEP} while waiting for alignment cluster";
	sleep $SLEEP
done

echo "starting dataflow"
source ./gcloud/dataflow/start_dataflow.sh 


##NEXT STEPS , SYNCHRONISE LOCAL DATA DIR WITH CLOUD BUCKET
#
echo "gs://${PROJECT}/Uploads directory";

echo "Next run bash ./gcloud/realtime/rt-sync.sh  local_path_to_fastq ${UPLOAD_BUCKET}"
echo "The results can be visualised at: ${URL}"
echo "Once finished make sure you shutdown aligner cluster (on cloud shell) with  bash ./gcloud/shutdown.sh"



