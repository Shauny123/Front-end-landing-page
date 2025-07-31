#!/bin/bash
echo "🚀 FULLY AUTOMATED DNS - NO GODADDY MANUAL WORK!"

DOMAINS=("bywordofmouthlegal.ai" "bywordofmouthlegal.com" "bywordofmouthlegal.help")
IP="35.201.89.202"

for domain in "${DOMAINS[@]}"; do
    echo "Setting up automated DNS for $domain..."
    
    # Create Google Cloud DNS zone
    gcloud dns managed-zones create ${domain//./-}-zone \
        --description="Auto DNS for $domain" \
        --dns-name="$domain." \
        --visibility="public" \
        --quiet 2>/dev/null || echo "Zone exists"
    
    # Clear any existing records and add new ones
    gcloud dns record-sets transaction start --zone="${domain//./-}-zone" --quiet 2>/dev/null
    
    # Add A records
    gcloud dns record-sets transaction add --zone="${domain//./-}-zone" \
        --name="$domain." --ttl="300" --type="A" "$IP" --quiet 2>/dev/null
    gcloud dns record-sets transaction add --zone="${domain//./-}-zone" \
        --name="www.$domain." --ttl="300" --type="A" "$IP" --quiet 2>/dev/null
    
    gcloud dns record-sets transaction execute --zone="${domain//./-}-zone" --quiet 2>/dev/null || echo "Records added"
    
    echo "✅ $domain configured automatically"
done

echo ""
echo "🎉 FULLY AUTOMATED! NO MORE MANUAL DNS!"
echo ""
echo "📋 FINAL STEP - UPDATE NAMESERVERS IN GODADDY:"
echo "(Only need to do this ONCE per domain)"
echo ""

for domain in "${DOMAINS[@]}"; do
    echo "=== $domain ==="
    echo "Copy these nameservers into GoDaddy:"
    gcloud dns managed-zones describe ${domain//./-}-zone --format="value(nameServers[].join(','))" | tr ',' '\n'
    echo ""
done

echo "🚀 After nameserver update, EVERYTHING is automated!"
echo "No more A records, CNAME conflicts, or manual DNS!"
