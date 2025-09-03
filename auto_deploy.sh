#!/bin/bash
echo "🤖 Auto-deploying ByWordOfMouthLegal (Fixed Version)..."

# Create proper web hosting with custom domain support
DOMAIN="bywordofmouthlegal.ai"
BUCKET_WEB="${DOMAIN}-web"

# Set up bucket for website hosting (with proper error checking)
if ! gsutil ls -b gs://${BUCKET_WEB} >/dev/null 2>&1; then
  echo "Bucket not found. Creating gs://${BUCKET_WEB}..."
  gsutil mb gs://${BUCKET_WEB}
  gsutil iam ch allUsers:objectViewer gs://${BUCKET_WEB}
else
  echo "Bucket gs://${BUCKET_WEB} already exists."
fi

gsutil web set -m index.html -e 404.html gs://${BUCKET_WEB}

# Copy files from the correct 'public' directory
echo "Copying files from public/ directory..."
gsutil -m cp -r public/* gs://${BUCKET_WEB}/

# Create global IP and load balancer
gcloud compute addresses create ${DOMAIN//./-}-ip --global --quiet 2>/dev/null || echo "IP exists"
IP=$(gcloud compute addresses describe ${DOMAIN//./-}-ip --global --format="value(address)")

# Create backend bucket
gcloud compute backend-buckets create ${DOMAIN//./-}-backend --gcs-bucket-name=${BUCKET_WEB} --enable-cdn --quiet 2>/dev/null || echo "Backend exists"

# Create URL map
gcloud compute url-maps create ${DOMAIN//./-}-map --default-backend-bucket=${DOMAIN//./-}-backend --quiet 2>/dev/null || echo "URL map exists"

# Create SSL certificate
gcloud compute ssl-certificates create ${DOMAIN//./-}-ssl --domains=${DOMAIN},www.${DOMAIN} --global --quiet 2>/dev/null || echo "SSL exists"

# Create HTTPS load balancer
gcloud compute target-https-proxies create ${DOMAIN//./-}-proxy --url-map=${DOMAIN//./-}-map --ssl-certificates=${DOMAIN//./-}-ssl --quiet 2>/dev/null || echo "Proxy exists"

# Create forwarding rule
gcloud compute forwarding-rules create ${DOMAIN//./-}-rule --address=${IP} --global --target-https-proxy=${DOMAIN//./-}-proxy --ports=443 --quiet 2>/dev/null || echo "Rule exists"

echo ""
echo "🎉 AUTOMATED SETUP COMPLETE!"
echo ""
echo "📋 UPDATE YOUR GODADDY DNS TO THESE VALUES:"
echo "Type: A"
echo "Name: @"
echo "Value: ${IP}"
echo ""
echo "Type: A"
echo "Name: www"
echo "Value: ${IP}"
echo ""
echo "⏰ After DNS update, your site will be live at:"
echo "https://${DOMAIN}"
echo "https://www.${DOMAIN}"
echo ""
echo "🔗 Current working URL:"
echo "https://storage.googleapis.com/${BUCKET_WEB}/index.html"
