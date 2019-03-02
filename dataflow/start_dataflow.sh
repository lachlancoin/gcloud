# Google Cloud project name
PROJECT=$(gcloud config get-value project)
# Apache Beam Runner (set org.apache.beam.runners.dataflow.DataflowRunner for running in a Google Cloud Dataflow or org.apache.beam.runners.direct.DirectRunner for running locally on your computer)
RUNNER=org.apache.beam.runners.dataflow.DataflowRunner

# specify mode of data processing (species, resistance_genes)
PROCESSING_MODE=species
# PubSub subscription defined above
UPLOAD_SUBSCRIPTION=projects/nano-stream1/subscriptions/dataflow_species

# size of the window (in wallclock seconds) in which FastQ records will be collected for alignment
ALIGNMENT_WINDOW=20
# how frequently (in wallclock seconds) are statistics updated for dashboard visualizaiton?
STATS_UPDATE_FREQUENCY=30

# Region where aligner cluster is running

if [ ! $ALIGNER_REGION ]; then
	echo "please define global parameter ALIGNER_REGION using e.g. export ALIGNER_REGION=\"asia-northeast1\""
fi

# IP address of the aligner cluster created by running aligner/provision_species.sh
SPECIES_ALIGNER_CLUSTER_IP=$(gcloud compute forwarding-rules describe bwa-species-forward --region=${ALIGNER_REGION} --format="value(IPAddress)")
# IP address of the aligner cluster created by running aligner/provision_resistance_genes.sh
#RESISTANCE_GENES_ALIGNER_CLUSTER_IP=$(gcloud compute forwarding-rules describe bwa-resistance-genes-forward --region=${ALIGNER_REGION} --format="value(IPAddress)")
# base URL for http services (bwa and kalign)
# value for species, for resistance_genes use 'SERVICES_HOST=http://$RESISTANCE_GENES_ALIGNER_CLUSTER_IP'
SERVICES_HOST=http://$SPECIES_ALIGNER_CLUSTER_IP
# bwa path
BWA_ENDPOINT=/cgi-bin/bwa.cgi
# bwa database name
BWA_DATABASE=genomeDB.fasta  #DB.fasta
# kalign path
KALIGN_ENDPOINT=/cgi-bin/kalign.cgi

RESISTANCE_GENES_LIST=gs://$PROJECT/Databases/resFinder/geneList

# Collections name prefix of the Firestore database that will be used for writing results
FIRESTORE_COLLECTION_NAME_PREFIX=new_scanning

## OPTIONAL ARGUMENTS

# Firestore database document name that will be used for writing statistic results. You can specify it otherwise it will be generated automatically
FIRESTORE_STATISTIC_DOCUMENT_NAME=statistic_document
# Max size of batch that will be generated before alignment. Default value - 2000
ALIGNMENT_BATCH_SIZE=2000
# Arguments that will be passed to BWA aligner (worker nodes machine_type). Default value - "-t 4". Can try "-t 8".
BWA_ARGUMENTS='-t 4'



if [ ! -e "./nanostream-dataflow/NanostreamDataflowMain/target/NanostreamDataflowMain-1.0-SNAPSHOT.jar" ]; then
	echo "Cannot find ./nanostream-dataflow/NanostreamDataflowMain/target/NanostreamDataflowMain-1.0-SNAPSHOT.jar"
	echo "please rebuild (see initialise_everything.sh)"
	exit 1;
fi

echo "java -cp ./nanostream-dataflow/NanostreamDataflowMain/target/NanostreamDataflowMain-1.0-SNAPSHOT.jar \
 com.google.allenday.nanostream.NanostreamApp \
 --runner=${RUNNER} \
 --region=${ALIGNER_REGION} \
 --project=${PROJECT} \
 --streaming=true \
 --processingMode=${PROCESSING_MODE} \
 --inputDataSubscription=${UPLOAD_SUBSCRIPTION} \
 --alignmentWindow=${ALIGNMENT_WINDOW} \
 --statisticUpdatingDelay=${STATS_UPDATE_FREQUENCY} \
 --servicesUrl=${SERVICES_HOST} \
 --bwaEndpoint=${BWA_ENDPOINT} \
 --bwaDatabase=${BWA_DATABASE} \
 --kAlignEndpoint=${KALIGN_ENDPOINT} \
 --outputFirestoreCollectionNamePrefix=${FIRESTORE_COLLECTION_NAME_PREFIX} \
 --outputFirestoreStatisticDocumentName=${FIRESTORE_STATISTIC_DOCUMENT_NAME} \
 --resistanceGenesList=${RESISTANCE_GENES_LIST} \
 --alignmentBatchSize=${ALIGNMENT_BATCH_SIZE} \
 --bwaArguments=${BWA_ARGUMENTS}
"

java -cp ./nanostream-dataflow/NanostreamDataflowMain/target/NanostreamDataflowMain-1.0-SNAPSHOT.jar \
 com.google.allenday.nanostream.NanostreamApp \
 --runner=$RUNNER \
 --region=$ALIGNER_REGION \
 --project=$PROJECT \
 --streaming=true \
 --processingMode=$PROCESSING_MODE \
 --inputDataSubscription=$UPLOAD_SUBSCRIPTION \
 --alignmentWindow=$ALIGNMENT_WINDOW \
 --statisticUpdatingDelay=$STATS_UPDATE_FREQUENCY \
 --servicesUrl=$SERVICES_HOST \
 --bwaEndpoint=$BWA_ENDPOINT \
 --bwaDatabase=$BWA_DATABASE \
 --kAlignEndpoint=$KALIGN_ENDPOINT \
 --outputFirestoreCollectionNamePrefix=$FIRESTORE_COLLECTION_NAME_PREFIX \
 --outputFirestoreStatisticDocumentName=$FIRESTORE_STATISTIC_DOCUMENT_NAME \
 --resistanceGenesList=$RESISTANCE_GENES_LIST \
 --alignmentBatchSize=$ALIGNMENT_BATCH_SIZE \
 --bwaArguments=$BWA_ARGUMENTS
