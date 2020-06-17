#This function starts a lambda function using main.zip, included in this file. The role arn currently needs to be updated when running
aws lambda create-function --function-name cloudComputeApiLambda --runtime go1.x \
    --zip-file fileb://main.zip --handler main \
    --role arn:aws:iam::455705935459:role/LambdaS3Permissions