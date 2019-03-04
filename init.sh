#!/bin/bash

PROJECT=$(gcloud config get-value project)
CLOUDSHELL=$(hostname | grep '^cs' | wc -l )
cd $HOME
if [ -e "./github" ]; then cd github ; fi



 
DATABASES="${PROJECT}/Databases"
SPECIES_DB="ToxoHumanBacteriaVirus"
RESISTANCE_DB="resFinder"

mkdir -p parameters
paramsfile="parameters/params"
if [ -e $paramsfile ]; then
	source $paramsfile
	if [ $OPTION ]; then
	 echo "there is an existing parameter file, so no need to specify an option.  Either move ${paramsfile} or run bash start.sh"
	 exit 1
	fi 

else
	OPTION=$1 
	if [ ! $OPTION ]; then
	 echo "usage bash start.sh|bwa-species|mm2-species|bwa-resistance|mm2-resistance"
	 exit 1
	fi 

	case $OPTION in
		'bwa-species') 
		 	SUBSCRIPTION="dataflow_species"
			BWA="gs://${DATABASES}/${SPECIES_DB}"
			NME="bwa-species"
			MT="n1-highmem-8"
			DOCKER='allenday/bwa-http-docker:http'
			file_to_check='genomeDB.fasta.bwt' ;
			file_to_check1='commontree.txt.css.mod' ;
		    ;;
		'mm2-species') 
		 	SUBSCRIPTION="dataflow_species_mm2"
			BWA="gs://${DATABASES}/${SPECIES_DB}"
			NME="bwa-species-mm2"
			MT="n1-highmem-8"
			DOCKER='dockersubtest/nano-gcp-http'
			file_to_check='genomeDB.fasta.mmi' ;
			file_to_check1='commontree.txt.css.mod' ;
		    ;;
		'bwa-resistance')  
		   	SUBSCRIPTION="dataflow_resistance"
			BWA="gs://${DATABASES}/${RESISTANCE_DB}"
			NME="bwa-resistance-genes"
			MT="n1-highmem-4"
			DOCKER='allenday/bwa-http-docker:http'
			file_to_check='DB.fasta.bwt' ;
			file_to_check1='commontree.txt.css.mod' ;
		    ;;
		'mm2-resistance')  
			SUBSCRIPTION="dataflow_resistance_mm2 "
			BWA="gs://${DATABASES}/${RESISTANCE_DB}"
			NME="bwa-resistance-genes-mm2"
			MT="n1-highmem-4"
			DOCKER='dockersubtest/nano-gcp-http'
			file_to_check='DB.fasta.mmi' ;
			file_to_check1='commontree.txt.css.mod' ;
		    ;;
		 \?) #unrecognized option 
		  	 echo "not recognised"
		  	 exit 1;
		    ;;
	esac

	#CHECK EVERYTHING SET UP ON CLOUD:
	checkbwa=$(gsutil ls $BWA | grep $file_to_check | wc -l )
	checkbwa1=$(gsutil ls $BWA | grep $file_to_check1 | wc -l )
	if [ "$checkbwa" -ne 1 ] ; then
		echo  "could not find ${file_to_check} in ${BWA}";
	exit 1;
	fi
	if [ "$checkbwa1" -ne 1 ] ; then
		echo  "could not find ${file_to_check1} in ${BWA}";
	exit 1;
	fi
	currdate=$(date '+%Y%m%d%H%m')

	export ALIGNER_REGION="asia-northeast1"
	export RESULTS_PREFIX=$currdate
	export UPLOAD_BUCKET="Uploads"; 
	export UPLOAD_EVENTS="UPLOAD_EVENTS"
	export REGION=$ALIGNER_REGION
	export ZONE="${REGION}-c"
	export MACHINE_TYPE="n1-highmem-4"
	export MIN_REPLICAS=1
	export MAX_REPLICAS=3
	export TARGET_CPU_UTILIZATION=0.5
	export UPLOAD_SUBSCRIPTION="projects/nano-stream1/subscriptions/${SUBSCRIPTION}"
	export BWA_FILES="${BWA}/*"
	export MACHINE_TYPE=$MT
	export NAME=$NME
	export DOCKER_IMAGE=$DOCKER
	export FORWARDER="${NAME}-forward";
	export REQUESTER_PROJECT=$(gcloud config get-value project)
	export RESISTANCE_GENES_LIST=gs://$DATABASES/$RESISTANCE_DB/geneList
	##SAVE PARAMETERS

	if [ -e $paramsfile ]; then
		source $paramsfile
		#dinfo=$(stat --printf='%Y\t%n\n' $paramsfile | cut -f 1)
		#mv $paramsfile "parameters/params_${dinfo}"
	else
		echo "export ALIGNER_REGION=\"${ALIGNER_REGION}\"" > $paramsfile
		echo "export RESULTS_PREFIX=\"${RESULTS_PREFIX}\"" >> $paramsfile
		echo "export UPLOAD_BUCKET=\"${UPLOAD_BUCKET}\"" >> $paramsfile
		echo "export UPLOAD_EVENTS=\"${UPLOAD_EVENTS}\"" >> $paramsfile
		echo "export REGION=\"${REGION}\"" >> $paramsfile
		echo "export ZONE=\"${ZONE}\"" >> $paramsfile
		echo "export MACHINE_TYPE=\"${MACHINE_TYPE}\"" >> $paramsfile
		echo "export MIN_REPLICAS=\"${MIN_REPLICAS}\"" >> $paramsfile
		echo "export MAX_REPLICAS=\"${MAX_REPLIACES}\"" >> $paramsfile
		echo "export TARGET_CPU_UTILIZATION=\"${TARGET_CPU_UTILIZATION}\"" >> $paramsfile
		echo "export UPLOAD_SUBSCRIPTION=\"${UPLOAD_SUBSCRIPTION}\"" >> $paramsfile
		echo "export BWA_FILES=\"${BWA_FILES}\"" >> $paramsfile
		echo "export MACHINE_TYPE=\"${MACHINE_TYPE}\"" >> $paramsfile
		echo "export NAME=\"${NAME}\"" >> $paramsfile
		echo "export DOCKER_IMAGE=\"${DOCKER_IMAGE}\"" >> $paramsfile
		echo "export FORWARDER=\"${FORWARDER}\"" >> $paramsfile
		echo "export DATABASES=\"${DATABASES}\"" >> $paramsfile
		echo "export SPECIES_DB=\"${SPECIES_DB}\"" >> $paramsfile
		echo "export RESISTANCE_DB=\"${RESISTANCE_DB}\"" >> $paramsfile
		echo "export RESISTANCE_GENES_LIST=\"${RESISTANCE_GENES_LIST}\"" >> $paramsfile
		gsutil rsync parameters gs://$PROJECT/parameters
	fi
fi




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
if [ ! -e "./nanostream-dataflow/NanostreamDataflowMain/target/NanostreamDataflowMain-1.0-SNAPSHOT.jar" ]; then
	echo "BUILDING UBER JAR"
	if [ ! -e './nanostream-dataflow/NanostreamDataflowMain/libs/japsa.jar' ]; then
		echo 'cannot find ./NanostreamDataflowMain/libs/japsa.jar'
		exit 1
	fi
	if [ "$CLOUDSHELL" -eq 1 ]; then
		#JUST BUILD IF ON CLOUD
		cd ./nanostream-dataflow/
	
		mvn install:install-file -Dfile=NanostreamDataflowMain/libs/japsa.jar -DgroupId=coin -DartifactId=japsa -Dversion=1.9-3c -Dpackaging=jar
		mvn install:install-file -Dfile=NanostreamDataflowMain/libs/pal1.5.1.1.jar -DgroupId=nz.ac.auckland -DartifactId=pal -Dversion=1.5.1.1 -Dpackaging=jar
		cd NanostreamDataflowMain
		mvn clean package
		if [ ! -e './target/NanostreamDataflowMain-1.0-SNAPSHOT.jar' ]; then
		  echo 'not successfully built'
		  exit 1;
		fi
		cd ../..  #back to top level
	fi
fi

##PROVISION aligner cluster
	echo "gcloud compute forwarding-rules describe ${FORWARDER} --region=${ALIGNER_REGION} --format=\"value(IPAddress)\"  | wc -l"
provisioned=$(gcloud compute forwarding-rules describe ${FORWARDER} --region=${ALIGNER_REGION} --format="value(IPAddress)"  | wc -l )
if [ "$provisioned" -eq 0 ]; then 
	if [ "$CLOUDSHELL" -eq 1 ]; then
		source ./gcloud/aligner/provision_internal.sh
		echo "provisioning aligner cluster"
		setup
	fi
else 
	echo "already provisioned"
	#fi
fi





SLEEP=60
while [ "$provisioned" -eq 0 ]; do
	echo "gcloud compute forwarding-rules describe ${FORWARDER} --region=${ALIGNER_REGION} --format=\"value(IPAddress)\"  | wc -l"
	provisioned=$(gcloud compute forwarding-rules describe ${FORWARDER} --region=${ALIGNER_REGION} --format="value(IPAddress)" | wc -l)
	echo "sleeping ${SLEEP} while waiting for alignment cluster";
	sleep $SLEEP
done


if [ "$CLOUDSHELL" -eq 1 ]; then
	
	NEWJOBID=$(gcloud dataflow jobs list | grep 'Running' | head -n 1 | cut -f 1 -d  ' ')
	if [ $NEWJOBID ]; then
		echo "warning there is already a dataflow job running ${NEWJOBID}";
	fi
	if [ $JOBID ] && [ $NEWJOBID ] && [ $NEWJOBID == $JOBID ];  then
		echo "dataflow job is running already";
	else
		echo "starting dataflow"
		source ./gcloud/dataflow/start_dataflow.sh 
		JOBID=$(gcloud dataflow jobs list | head -n 2 | grep -v 'JOB_ID' | cut -f 1 -d  ' ')
		echo "export JOBID=\"${JOBID}\"" >> $paramsfile
	fi	


fi




##NEXT STEPS , SYNCHRONISE LOCAL DATA DIR WITH CLOUD BUCKET
#
echo "gs://${PROJECT}/Uploads directory";
echo "JOBID: ${JOBID}"
echo "Next run bash ./gcloud/realtime/rt-sync.sh  local_path_to_fastq ${UPLOAD_BUCKET}"
echo "The results can be visualised at: ${URL}"
echo "Once finished make sure you shutdown aligner cluster (on cloud shell) with  bash ./gcloud/shutdown.sh"



