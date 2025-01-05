#!/bin/bash
#aws ec2 run-instances --image-id $ImageId --count 1 --instance-type t2.micro --key-name <Keypair-name> --security-group-ids SecurityGroupId
#NAMES=("mongodb" "redis" "mysql" "rabbitmq" "catalogue" "user" "cart" "shipping" "payment" "dispatch" "web")

#####var######
NAME=$@
ImageId=ami-0b4f379183e5706b9
SecurityGroupId=sg-0d41613ba45142319
DomainName=bomma.store
InstanceType=""
HostedZoneId=Z029188032MG5FWK5IWMU

########
for i in $@
do
    if [$i == mysql || $i == mongodb]
    then
      InstanceType="t3.medium"
    else
      InstanceType="t2.micro"
    fi
    echo "creating $i instance"
    Ip_Address=$('aws run-instances --image-id $ImageId --instance-type $InstanceType --security-group-ids $SecurityGroupId'--tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$i}]" | jq -r '.Instances[0].PrivateIpAddress')
    aws route53 change-resource-record-sets --hosted-zone-id $HOSTED_ZONE_ID --change-batch '
    {
            "Changes": [{
            "Action": "CREATE",
                        "ResourceRecordSet": {
                            "Name": "'$i.$DOMAIN_NAME'",
                            "Type": "A",
                            "TTL": 300,
                            "ResourceRecords": [{ "Value": "'$IP_ADDRESS'"}]
                        }}]
    }
    '

done