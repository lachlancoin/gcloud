##CREATE TOPIC UPLOAD_EVENTS here first
##THIS IS JUST FOR BWA_SPECIES NOTIFICATIONS
##NEED TO ADD RESISTANCE TYPING NOTIFS
##https://console.cloud.google.com/cloudpubsub/topicList?project=nano-stream1

PROJECT=$(gcloud config get-value project)

if [ ! $UPLOAD_BUCKET ] ; then
 echo "please define UPLOAD_BUCKET";
 exit 1;
fi

if [ ! $UPLOAD_SUBSCRIPTION ] ; then
 echo "please define UPLOAD_SUBSCRIPTION";
 exit 1;
fi

if [ ! $UPLOAD_EVENTS ] ; then
 echo "please define UPLOAD_EVENTS";
 exit 1;
fi

bucket=$(gsutil ls gs://${PROJECT} | grep "${PROJECT}/${UPLOAD_BUCKET}/")
if [ ! $bucket ]; then 
	echo "could not find ${PROJECT}/${UPLOAD_BUCKET}";
	exit 1;
fi



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



