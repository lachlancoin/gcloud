PROJECT=$(gcloud config get-value project)


CLOUDSHELL=$(hostname | grep '^cs' | wc -l )
echo "CLOUDSHELL "$cloudshell

cd $HOME
if [ -e "./github" ]; then cd github ; fi
if [ $1 ]; then
	source $1
else
	source parameters/params
fi

gcloud compute forwarding-rules describe ${FORWARDER} --region=${ALIGNER_REGION} --format="value(IPAddress)"

echo "gcloud compute forwarding-rules describe ${FORWARDER} --region=${ALIGNER_REGION} --format=\"value(IPAddress)\" | wc -l"
provisioned=$(gcloud compute forwarding-rules describe ${FORWARDER} --region=${ALIGNER_REGION} --format="value(IPAddress)"  | wc -l)
echo "IP: ${provisioned}"
