##CREATE TOPIC UPLOAD_EVENTS here first
##THIS IS JUST FOR BWA_SPECIES NOTIFICATIONS
##NEED TO ADD RESISTANCE TYPING NOTIFS
##https://console.cloud.google.com/cloudpubsub/topicList?project=nano-stream1

PROJECT=$(gcloud config get-value project)




UPLOAD_EVENTS=UPLOAD_EVENTS
UPLOAD_BUCKET=Uploads
UPLOAD_SUBSCRIPTION="projects/${PROJECT}/subscriptions/dataflow_species"

##CHECK notifications
notif=$(gsutil notification list gs://nano-stream1 | grep $UPLOAD_EVENTS | grep $PROJECT)

##CREATE NOTIFICATION FOR FILE UPLOADS
if [ ! $notif ] ; then
	echo "gsutil notification create -t ${UPLOAD_EVENTS} -f json  -e OBJECT_FINALIZE -p ${UPLOAD_BUCKET} gs://${PROJECT}"
	gsutil notification create -t $UPLOAD_EVENTS -f json  -e OBJECT_FINALIZE -p $UPLOAD_BUCKET "gs://"$PROJECT
fi

##CREATE SUBSCRIPTION
subs=$(gcloud pubsub subscriptions list | grep $UPLOAD_SUBSCRIPTION | grep $PROJECT)
if [ ! $subs ] ; then
	echo "gcloud pubsub subscriptions create ${UPLOAD_SUBSCRIPTION} --topic ${UPLOAD_EVENTS}"
	gcloud pubsub subscriptions create $UPLOAD_SUBSCRIPTION --topic $UPLOAD_EVENTS
fi



