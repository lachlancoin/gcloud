# gcloud

Steps

1. Log into cloud shell from https://console.cloud.google.com

2. Set up firestore as part of gcloud account setup

3. Open google cloud shell

4. On cloud shell run `git clone https://github.com/lachlancoin/gcloud.git`

5. On cloud shell run `bash ./gcloud/init.sh bwa_species`

6. From local computer run `bash ./gcloud/realtime/rt-sync.sh  local_path_to_fastq Uploads`

7. Results can be seen on https://{PROJECT}.appspot.com (for example, https://nano-stream1.appspot.com)

8. When finished, on cloud shell run `bash ./gcloud/shutdown.sh`

Results 

 

Following steps have been automated, I've archived them below in case errors are found in the future and they need to be done through the GUI.
2.1 Create storage bucket called "Uploads" atomated in init.sh
2.2 Set up UPLOAD_EVENTS topic at https://console.cloud.google.com/cloudpubsub/topicList
