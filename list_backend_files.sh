#!/bin/bash
# This script lists all files in the backend storage bucket.

# The bucket name is based on the corrected deployment script.
BUCKET_NAME="bywordofmouthlegal.ai-web-durable-trainer-466014-h8"

echo "Listing all files in bucket: ${BUCKET_NAME}"
echo "-------------------------------------------"

gsutil ls -R gs://${BUCKET_NAME}
