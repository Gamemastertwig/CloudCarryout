#!/bin/bash

# This function starts a lambda function using main.zip, included in this file. 
# The role arn currently needs to be updated when running
# (modified form script made by Neo)
aws lambda create-function --function-name trigger-aws-batch-job --runtime go1.x \
    --zip-file fileb://main.zip --handler main \
    --role arn:aws:iam::[YOURAWSIDNUM]:role/LambdaS3Permissions