package main

import (
	"fmt"

	"github.com/aws/aws-lambda-go/lambda"
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/batch"
)

func main() {
	lambda.Start(Handler)
}

//Handler request from Lambda
func Handler() (string, error) {

	svc := batch.New(session.New())
	input := &batch.SubmitJobInput{
		JobDefinition: aws.String("cloudcarryout-batch-job-test"),
		JobName:       aws.String("testJob"),
		JobQueue:      aws.String("cloudcarryout-batch-job-queue"),
	}

	results, err := svc.SubmitJob(input)
	if err != nil {
		fmt.Println(err.Error())
		return "", err
	}

	fmt.Println(results)
	return fmt.Sprintln(results), nil
}
