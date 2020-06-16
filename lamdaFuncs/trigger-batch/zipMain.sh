!#/bin/bash

# (modified form script made by Neo)
GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build -o main
zip main.zip main