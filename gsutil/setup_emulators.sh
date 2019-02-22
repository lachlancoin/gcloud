## need to install gcloud first
#https://cloud.google.com/sdk/docs/quickstart-debian-ubuntu


##INSTALL GOOGLE CLOUD
# Create environment variable for correct distribution
export CLOUD_SDK_REPO="cloud-sdk-$(lsb_release -c -s)"
# Add the Cloud SDK distribution URI as a package source
echo "deb http://packages.cloud.google.com/apt $CLOUD_SDK_REPO main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
# Import the Google Cloud Platform public key
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
# Update the package list and install the Cloud SDK
sudo apt-get update && sudo apt-get install google-cloud-sdk

sudo apt-get update && sudo apt-get install google-cloud-sdk-app-engine-java
sudo apt-get update && sudo apt-get install  google-cloud-sdk-pubsub-emulator
sudo apt-get update && sudo apt-get install  kubectl
sudo apt-get update && sudo apt-get install  google-cloud-sdk-datastore-emulator
## see: https://cloud.google.com/sdk/gcloud/reference/beta/emulators/pubsub/

##https://firebase.google.com/docs/cli/
sudo apt-get install npm
npm install -g firebase-tools
firebase login --no-localhost
https://firebase.google.com/docs/cli/
mkdir firebase
firebase init
firebase setup:emulators:firestore
#? Which Firebase CLI features do you want to setup for this folder? Press Space to select features, then Enter to confirm your choices. (Press <space> to select)
#❯◯ Database: Deploy Firebase Realtime Database Rules
# ◯ Firestore: Deploy rules and create indexes for Firestore
# ◯ Functions: Configure and deploy Cloud Functions
# ◯ Hosting: Configure and deploy Firebase Hosting sites
# ◯ Storage: Deploy Cloud Storage security rules


##NEED MAVEN
sudo apt install maven



##INSTALLING BEAM:
#https://beam.apache.org/get-started/quickstart-java/


##WORD COUNT - get word count example for data flow
mvn archetype:generate \
      -DarchetypeGroupId=org.apache.beam \
      -DarchetypeArtifactId=beam-sdks-java-maven-archetypes-examples \
      -DarchetypeVersion=2.9.0 \
      -DgroupId=org.example \
      -DartifactId=word-count-beam \
      -Dversion="0.1" \
      -Dpackage=org.apache.beam.examples \
      -DinteractiveMode=false



##run word count using direct runner
 #mvn compile exec:java \
 #     -Dexec.mainClass=org.apache.beam.examples.WordCount \
  #    -Dexec.args="--output=./output/"


mvn compile exec:java -Dexec.mainClass=org.apache.beam.examples.WordCount \
     -Dexec.args="--inputFile=pom.xml --output=counts" -Pdirect-runner

##E-UTILS
#get an api key: https://www.ncbi.nlm.nih.gov/account/settings/
https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?db=pubmed&id=123456&api_key=fc1dbd72ef331a2e234c0ba80b230ad50f08 




sudo apt-get install google-cloud-sdk-pubsub-emulator
gcloud beta emulators pubsub env-init
gcloud beta emulators firestore start


#https://cloud.google.com/datastore/docs/export-import-entities#exporting_entities
