# Lista buckets em todas as regiões
for region in $(aws ec2 describe-regions --query 'Regions[].RegionName' --output text); do
    echo "Region: $region"
    aws s3api list-buckets --region $region
    echo "\n"
done
