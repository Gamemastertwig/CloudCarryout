package main

import (
	"bytes"
	"encoding/json"
	"errors"
	"fmt"

	"github.com/aws/aws-lambda-go/lambda"
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/s3/s3manager"
)

func main() {
	lambda.Start(Handler)
}

//Handler request from Lambda
func Handler(request map[string]interface{}) (string, error) {

	//Parse request
	mssg, err := json.Marshal(request)
	if err != nil {
		fmt.Println(err.Error())
		return "Request cannot be parsed", errors.New("Error: cannot parse request")
	}

	//Create new session and uploader
	sess := session.Must(session.NewSession())
	up := s3manager.NewUploader(sess)

	//Upload request json
	_, err = up.Upload(&s3manager.UploadInput{
		Bucket: aws.String("jenkins-cicd-s3"),
		Key:    aws.String("key"),
		Body:   bytes.NewReader(mssg),
	})
	return "woot", nil
}
