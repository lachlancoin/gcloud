##CREATE TOPIC UPLOAD_EVENTS
##https://console.cloud.google.com/cloudpubsub/topicList?project=nano-stream1

UPLOAD_EVENTS=UPLOAD_EVENTS
UPLOAD_BUCKET=Uploads
PROJECT="gs://nano-stream1"

UPLOAD_SUBSCRIPTION="projects/nano-stream1/subscriptions/dataflow_species"

##CREATE NOTIFICATION
gsutil notification create -t $UPLOAD_EVENTS -f json  -e OBJECT_FINALIZE -p $UPLOAD_BUCKET $PROJECT


##CREATE SUBSCRIPTION
gcloud pubsub subscriptions create $UPLOAD_SUBSCRIPTION --topic $UPLOAD_EVENTS

#gsutil notification create -t $UPLOAD_EVENTS -f json -e OBJECT_FINALIZE $UPLOAD_BUCKET

