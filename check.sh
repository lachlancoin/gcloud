PROJECT=$(gcloud config get-value project)


CLOUDSHELL=$(hostname | grep '^cs' | wc -l )
echo "CLOUDSHELL "$cloudshell
mkdir -p parameters

OPTION=$1 
export RESNAME=$2

if [ ! $1 ] || [ ! $2 ]; then
	 echo "usage bash check.sh|bwa-species|mm2-species|bwa-resistance|mm2-resistance  res_prefix"
	 exit 1
else
	paramsfile="parameters/params-${OPTION}-${RESNAME}"
fi 





cd $HOME
if [ -e "./github" ]; then cd github ; fi
echo "gsutil cp  gs://$PROJECT/${paramsfile} ${paramsfile}"
gsutil cp  gs://$PROJECT/${paramsfile} $paramsfile


source $paramsfile


gcloud compute forwarding-rules describe ${FORWARDER} --region=${ALIGNER_REGION} --format="value(IPAddress)"

echo "gcloud compute forwarding-rules describe ${FORWARDER} --region=${ALIGNER_REGION} --format=\"value(IPAddress)\" | wc -l"
provisioned=$(gcloud compute forwarding-rules describe ${FORWARDER} --region=${ALIGNER_REGION} --format="value(IPAddress)"  | wc -l)
echo "IP: ${provisioned}"


gcloud pubsub subscriptions list | grep 'name' | grep ${UPLOAD_SUBSCRIPTION} |  cut -f 2 -d ' ' 
subscriptions=$(gcloud pubsub subscriptions list | grep 'name' | grep ${UPLOAD_SUBSCRIPTION} |  cut -f 2 -d ' '  | wc -l)
echo "subscriptions:  ${subscriptions}"

notif=$(gsutil notification list gs://nano-stream1 | grep $UPLOAD_EVENTS | grep $PROJECT | wc -l )
echo "notifications: ${notifications}"
