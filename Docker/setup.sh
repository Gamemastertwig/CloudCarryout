#!/bin/bash

aws configure set aws_access_key_id ${AWS_ACCESS_KEY_ID}
aws configure set aws_secret_access_key ${AWS_SECRET_ACCESS_KEY}

# code to determine which script to run
# get json from s3 bucket
aws s3 cp s3://brandonlocker-test/jobs/job.json .
if [[ $? -eq 0 ]]
then
    echo "Job found!"
else
    # exit 2 if no job.json found
    echo "No Job found!"
    exit 2
fi

# function for initing terraform and applying it
func_terraform() {
    terraform init
    terraform apply -auto-approve
}

# webApp
grep -q "\"webApp\"" job.json
if [[ $? -eq 0 ]]
then
    echo "Provisioning webApp resources..."
    cd terraform/webApp
    func_terraform
    exit 0
fi

# windowsApp
grep -q "\"windowApp\"" job.json
if [[ $? -eq 0 ]]
then
    echo "Provisioning windowApp resources..."
    cd terraform/testing
    func_terraform
    exit 0
fi

# msmq
grep -q "\"msmq\"" job.json
if [[ $? -eq 0 ]]
then
    echo "Provisioning msmq resources..."
fi

# no valid selection
echo "No valid selection found, no resources provisioned."
exit 1
