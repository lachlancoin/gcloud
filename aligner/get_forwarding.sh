#!/bin/bash
ALIGNER_REGION=asia-northeast1
gcloud compute forwarding-rules describe bwa-species-forward --region=${ALIGNER_REGION} --format="value(IPAddress)"
