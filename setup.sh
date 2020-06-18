#!/bin/bash

# set up AWS CLI
aws configure set aws_access_key_id ${AWS_ACCESS_KEY_ID}
aws configure set aws_secret_access_key ${AWS_SECRET_ACCESS_KEY}
aws configure set default.region ${AWS_REGION}

# code to determine which script to run
# get json from s3 bucket
aws s3 cp s3://${AWS_BUCKET}/${FILE_TO_WATCH} .
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
    # folder stores the desired folder ($1 argument passed to func_terraform)
    folder=$1
    cd terraform/${folder}
    terraform init -backend-config=tfBackendConfig
    terraform apply -auto-approve
    aws s3 rm s3://${AWS_BUCKET}/${FILE_TO_WATCH}
    exit 0
}

# webApp
grep -q "\"webApp\"" job.json
if [[ $? -eq 0 ]]
then
    echo "Provisioning webApp resources..."
    func_terraform webApp
fi

# windowsApp
grep -q "\"windowsApp\"" job.json
if [[ $? -eq 0 ]]
then
    echo "Provisioning windowsApp resources..."
    func_terraform windowsApp
fi

# msmq
grep -q "\"msmq\"" job.json
if [[ $? -eq 0 ]]
then
    echo "Provisioning msmq resources..."
    func_terraform msmq
fi

# no valid selection
echo "No valid selection found, no resources provisioned."
aws s3 rm s3://${AWS_BUCKET}/${FILE_TO_WATCH}
exit 1
