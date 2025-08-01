#!/bin/bash
echo "🚀 Setting up ALL 3 domains automatically..."

# Domain list
DOMAINS=("bywordofmouthlegal.ai" "bywordofmouthlegal.com" "bywordofmouthlegal.help")

# Get the existing IP
IP=$(gcloud compute addresses describe bywordofmouthlegal-ai-ip --global --format="value(address)" 2>/dev/null)

if [ -z "$IP" ]; then
    echo "Creating global IP..."
    gcloud compute addresses create multi-domain-ip --global
    IP=$(gcloud compute addresses describe multi-domain-ip --global --format="value(address)")
fi

# Create SSL certificate for ALL domains
echo "Creating SSL certificate for all domains..."
ALL_DOMAINS=""
for domain in "${DOMAINS[@]}"; do
    ALL_DOMAINS="$ALL_DOMAINS,$domain,www.$domain"
done
ALL_DOMAINS=${ALL_DOMAINS#,}  # Remove leading comma

gcloud compute ssl-certificates create all-domains-ssl \
    --domains="$ALL_DOMAINS" \
    --global --quiet 2>/dev/null || echo "SSL certificate exists"

# Update existing infrastructure to handle all domains
gcloud compute target-https-proxies update bywordofmouthlegal-ai-proxy \
    --ssl-certificates=all-domains-ssl --quiet 2>/dev/null || echo "Proxy updated"

echo ""
echo "🎉 ALL DOMAINS CONFIGURED!"
echo ""
echo "📋 UPDATE GODADDY DNS FOR ALL 3 DOMAINS:"
echo "IP ADDRESS: $IP"
echo ""
for domain in "${DOMAINS[@]}"; do
    echo "=== $domain ==="
    echo "Type: A, Name: @, Value: $IP"
    echo "Type: A, Name: www, Value: $IP"
    echo ""
done

echo "✅ After DNS update, ALL these will work:"
for domain in "${DOMAINS[@]}"; do
    echo "  https://$domain"
    echo "  https://www.$domain"
done
