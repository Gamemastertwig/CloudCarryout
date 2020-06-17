# CloudCarryout
A system for ordering infrastructure from AWS based on package needed by the user.


AWS API Gateway

AWS Lambda Function

AWS S3 Bucket

AWS Lambda Function
- trigger-aws-batch-job
	
	This lambda function was written in Go. You can apply it to your pipeline by running the following commands
	in the lambdaFuncs > trigger-batch folder.
	`go mod init trigger-batch`
	`./zipMain.sh`
	If first time running, ie: function does not already exist in your AWS environment.
	`./lambdaStart.sh`
	Else
	`./updateLambda.sh`
	
	An event will need to be setup on the s3 bucket from above. 
	You can create an event by going to your bucket then select "Properties" then "Events". Select "Add
	notification". Name your event whatever you like, select "all object create events" ........

AWS Batch
- Compute environments
- Job queues
- Job definitions
- Jobs


Terraform Scripts

Dockerfile
