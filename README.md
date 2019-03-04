# gcloud





#Manual steps:
#1. Set up firestore as part of gcloud account setup
#2. Create storage bucket  $UPLOAD_BUCKET
#3. Set up UPLOAD_EVENTS topic at https://console.cloud.google.com/cloudpubsub/topicList?project=nano-stream1
#4 . Log into cloud shell from https://console.cloud.google.com
#5. On cloud shell run  git clone https://github.com/lachlancoin/gcloud.git
#6. On cloud she run  bash ./gcloud/init.sh bwa_species
#7. From local computer Run:  bash ./gcloud/realtime/rt-sync.sh  local_path_to_fastq $UPLOAD_BUCKET
#8. When finished run bash ./gcloud/shutdown.sh
