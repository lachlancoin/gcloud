java -cp /home/coingroupimb/nanostream-dataflow/NanostreamDataflowMain/target/NanostreamDataflowMain-1.0-SNAPSHOT.jar \
 com.google.allenday.nanostream.NanostreamApp \
 --region=asia-northeast1 \
 --runner=org.apache.beam.runners.dataflow.DataflowRunner \
 --project=nano-stream1 \
 --streaming=true \
 --processingMode=species \
 --inputDataSubscription=projects/nano-stream1/subscriptions/dataflow_species \
 --alignmentWindow=20 \
 --statisticUpdatingDelay=30 \
 --servicesUrl=http://35.201.96.177/ \
 --bwaEndpoint=/cgi-bin/bwa.cgi \
 --bwaDatabase=genomeDB.fasta \
 --kAlignEndpoint=/cgi-bin/kalign.cgi \
 --outputFirestoreCollectionNamePrefix=new_scanning
