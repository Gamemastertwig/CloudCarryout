# CloudCarryout
A system for ordering infrastructure from AWS based on package needed by the user.

Orders are placed using json and AWS API Gateway

{"template":"webApp"} -> Provisions an t2.micro Linux EC2, an RDS database, and a load balancer on their own VPC
{"template":"windowsApp"} -> Provisions an t2.micro Windows EC2, and an RDS database on their own VPC
{"template":"msmq"} -> Provisions a SQS, and an S3 bucket

## Prequesits
IAM User: 
Any user with permisions to create EC2, DBs, VPCs, etc. will do. If you do not have one you will need to create the user in the IAM console.
    You will need both their Access Key and Secret Key

IAM Role: 
Create a new roll called `LambdaS3Permissions`
It needs AmazonS3FullAccess and AWSLambdaFullAccess polocies applyed

AWS S3 Bucket:

## Need Setup
**AWS Lambda Function**
**- cloudComputeApiLambda (Go)**

	This lambda function was written in Go. 
	
	There are two items that must be changed in order to start the lambda function. The first is inside the go code, AWS_BUCKET must be changed to reflect the bucket that you would like the batch job to pull from. Note: this does not change the bucket the batch job pulls from. That resource must be changed in the following section, AWS Lambda Function. 
	
	The second item that must be changed is inside apiLambdaSart.sh. The ARN in this script needs to be updated with the ARN of the IAM that was created for the two Lambda functions. Once again, ensure that this IAM role as full s3 permissions for this to work. 

	Now that those two items are updated, follow the following steps inside of lambdaFuncs > api-lambda folder in order to start the lambda function.
	- `go mod init qpi-lambda`
	- `./zipMain.sh`
	- `./apiLambdaStart`

	The Lambda function should now be started. In order to update the Lambda, run `./zipMain.sh` and then `./updateLambda.sh`

**AWS API Gateway**

	The following steps are to set up a restful AWS API Gateway connected to the previous Lambda function. Follow these steps, starting from the `Choose API Type` screene
	- Find `Rest API` and click `Build`
	- Ensure protocol is on `REST`, and `New API` has been selected
	- Enter the name you would like, along with a description and make sure the `Endpoint Type` is `Regional`
	- Click `Create`
	- You should now be on the `Resources` screne
	- Click `Actions` > `Create Resource`
	- Name the resource `request` this will update the path, and then click `Create Resource`
	- Back on the `Resources` page, click `Actions` > `Create Method`
	- Click the `drop down` and then select `POST` click the checkmark
	- Integration type should be `Lambda Function` and region should be whatever region the Lambda function was created in
	- Search for the Lambda function in the `Lambda Function` box and click `save` then `ok` to give the API Gateway permissions
	- You should now be on the `Method Execution` screen
	- Click `test`
	- In `Request Body`, enter whatever template you whould like to envoke. JSON format must be used here. For example, {"template":"webApp"}
	- The following templates are supported: `webApp`, `windowsApp`, `msmq`

**AWS Lambda Function**
**- trigger-aws-batch-job (Go)**

	This lambda function was written in Go. You can apply it to your pipeline by running the following commands
	in the lambdaFuncs > trigger-batch folder.
	`go mod init trigger-batch`
	`./zipMain.sh`
	If first time running, ie: function does not already exist in your AWS environment.
    edit `lambdaStart.sh` and replace `[YOURAWSIDNUM]` with you AWS Account ID Number (can be found on bottom left of IAM window), make sure to remove the []s as well.
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
[insert list later]

**Dockerfile**

The dockerfile is the blueprint for the docker image stored at https://hub.docker.com/repository/docker/brandonlocker/cloudcarryout.
It setups the environment need to deploy the Terraform scripts and provision the resources. The environment includes AWS CLI and Terraform installations. The following environtmental variables are needed for the image to work.

- AWS_REGION = us-east-1 (region you want the resources provisioned in)
- AWS_ACCESS_KEY_ID = ABCD...... (this needs to be the access key for the IAM user with permissions to provision the resources)
- AWS_SECRET_ACCESS_KEY = dka2jd1.... (secret key for IAM user above)
- AWS_BUCKET = myBucket (name of the bucket the job.json is being saved in)
- FILE_TO_WATCH = jobs/job.json (file holding the json that is used to determine what resources to deploy)

Example:
```shell
$ docker run -it --env AWS_ACCESS_KEY_ID=xxxxxxxxxxxxxxxxxx --env AWS_SECRET_ACCESS_KEY=xxxxxxxxxxxxxxxxxxxx --env AWS_BUCKET=brandonlocker-test --env FILE_TO_WATCH=jobs/job.json --env AWS_REGION=us-east-1 brandonlocker/cloudcarryout
```
Also the file to watch will need to be stored in the s3 bucket refrenced in the env variable or the script running will fail. 