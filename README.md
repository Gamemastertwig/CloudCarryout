# CloudCarryout
A system for ordering infrastructure from AWS based on package needed by the user.

## Prequesits
IAM User:

IAM Role: LambdaS3Permissions

AWS S3 Bucket:

## Need Setup
AWS API Gateway


AWS Lambda Function
- cloudComputeApiLambda (G0)



**AWS Lambda Function**
- trigger-aws-batch-job (Go)

	This lambda function was written in Go. You can apply it to your pipeline by running the following commands
	in the lambdaFuncs > trigger-batch folder.
	`go mod init trigger-batch`
	`./zipMain.sh`
	If first time running, ie: function does not already exist in your AWS environment.
	run `./lambdaStart.sh`
	Else
	run `./updateLambda.sh`

	An event will need to be setup on the s3 bucket from above.
	You can create an event by going to your bucket then select "Properties" then "Events". Select "Add
	notification".
	- Name your event whatever you like.
	- Select "all object create events"
	- Prefix put `jobs`
	- Suffix put `job.json`
	- Send to select "Lambda Function" in dropdown
	- Lambda select "trigger-aws-batch-job"
	- Save

**AWS Batch**
Each section below should be completed in order. You can change the names suggested but if you do you will need to modify files in repo before setting them up

- Compute environments

	We need an environment to run our provisioning from. We used a Managed spot environment to keep resource costs down.
	- Go to Batch under Compute in services
	- Select "Compute environments" on left hand menu
	- Click "Create environment"
	- Select "Managed"
	- Compute environment name `cloudcarryout-comp-env`
	- Scroll down to "Provisioning model" select "Spot"
	- Leave all other setting as defualt
	- Click "Create"

- Job queues

	Next we need a queue to run the jobs in.
	- Select "Job queues" on left hand menu
	- Click "Create queue"
	- Queue name `cloudcarryout-batch-job-queue`
	- Priority `10`
	- Select "cloudcarryout-comp-env" from drop down
	- Click "Create Job Queue"

- Job definitions

	We need to create a job definition that defines the job to be ran.
	- Select "Job definitions" on left hand menu
	- Click "Create"
	- Job definition name ``
	- Job attempts `2`
	- Contaner image `brandonlocker/cloudcaarryout:latest` (if you modify the dockerfile and/or upload this elsewhere you will need to change this to that image)
	- vCPUS `1`
	- Memory `512`
	- Scroll down and click "add environment variable
	- Add the following keypairs ...
		- AWS_REGION = us-east-1 (region you want the resources provisioned in)
		- AWS_ACCESS_KEY_ID = ABCD...... (this needs to be the access key for the IAM user with permissions to provision the resources)
		- AWS_SECRET_ACCESS_KEY = dka2jd1.... (secret key for IAM user above)
		- AWS_BUCKET = myBucket (name of the bucket the job.json is being saved in)
		- FILE_TO_WATCH = jobs/job.json (should be same unless you modified cloudComputeApiLambda function)

- Jobs

	Are called by the trigger-aws-batch-job lambda function

## Provided (but may need edited)
**Terraform Scripts**

**Dockerfile**