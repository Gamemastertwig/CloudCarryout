#!/bin/bash

# updates existing lamda function 
# (modified form script made by Neo)
aws lambda update-function-code \
    --function-name trigger-aws-batch-job \
    --zip-file fileb://main.zip