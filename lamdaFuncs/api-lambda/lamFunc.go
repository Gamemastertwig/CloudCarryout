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

type request struct {
	Method string
	Template string
}
type params struct {
	Template string
}


//Handler request from Lambda
func Handler(event map[string]interface{}) (string, error) {


	//Parse request
	mssg, err := json.Marshal(event)
	if err != nil {
		fmt.Println(err.Error())
		return "Request cannot be parsed", errors.New("Error: cannot parse request event unmarshal")
	}	
	parm := params{}

	err = json.Unmarshal(mssg, &parm)
	if err != nil {
		fmt.Println(err.Error())
		return "Request cannot be parsed", errors.New("Error: cannot parse request event unmarshal")
	}
	req := request{
		Method: "request",
		Template: parm.Template,
	}

	mssg, err = json.Marshal(req)
	if err != nil {
		fmt.Println(err.Error())
		return "Request cannot be parsed", errors.New("Error: cannot parse request event unmarshal")
	}

	//Create new session and uploader
	sess := session.Must(session.NewSession())
	up := s3manager.NewUploader(sess)

	//Upload request json
	_, err = up.Upload(&s3manager.UploadInput{
		Bucket: aws.String("jenkins-cicd-s3"),
		Key:    aws.String("job.json"),
		Body:   bytes.NewReader(mssg),
	})

	return string("Request has been deposited"), nil
}
