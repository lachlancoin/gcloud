##JUST KILLS DATAFLOW BUT PRESERVES ALIGNER CLUSTER
PROJECT=$(gcloud config get-value project)
CLOUDSHELL=$(hostname | grep '^cs' | wc -l )
ACTION="cancel"
#ACTION="drain"
echo "CLOUDSHELL "$cloudshell
mkdir -p parameters
OPTION=$1 
export RESNAME=$2

if [ ! $1 ] || [ ! $2 ]; then
	 echo "usage bash kill_dataflow.sh|bwa-species|mm2-species|bwa-resistance|mm2-resistance  res_prefix"
	 exit 1
else
	paramsfile="parameters/params-${OPTION}-${RESNAME}"
fi 


cd $HOME
if [ -e "./github" ]; then cd github ; fi
echo "gsutil cp  gs://$PROJECT/${paramsfile} ${paramsfile}"
gsutil cp  gs://$PROJECT/${paramsfile} $paramsfile
source $paramsfile



if [ $JOBID ]; then
	gcloud dataflow jobs list | grep ${JOBID}  | cut -f 1 -d ' ' | xargs -I {} gcloud dataflow jobs --project=$PROJECT $ACTION --region=$ALIGNER_REGION {}
else
	gcloud dataflow jobs list | grep Running | cut -f 1 -d ' ' | xargs -I {} gcloud dataflow jobs --project=$PROJECT $ACTION --region=$ALIGNER_REGION {}
fi

