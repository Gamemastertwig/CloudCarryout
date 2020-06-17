FROM amazonlinux:latest

# Install AWS CLI
RUN echo "Installing AWS CLI..."
RUN yum -y install which unzip aws-cli

# Install Terraform
RUN echo "Installing Terraform..."
RUN curl -O https://releases.hashicorp.com/terraform/0.12.26/terraform_0.12.26_linux_amd64.zip
RUN unzip terraform_0.12.26_linux_amd64.zip -d /usr/bin/

# Copy over the test Terraform and setup script
WORKDIR /temp
COPY setup.sh /temp
RUN chmod +x setup.sh

# make terraform dir to hold scripts
RUN mkdir terraform

# transfer terraform files to perspective dir
WORKDIR /temp/terraform

# make dir(s)
RUN mkdir webApp
RUN mkdir windowsApp
RUN mkdir msmq

# webApp
COPY ./Terraform/webApp/EC2Linux.tf /temp/terraform/webApp
COPY ./Terraform/webApp/loadBalancer.tf /temp/terraform/webApp
COPY ./Terraform/webApp/sqlLin.tf /temp/terraform/webApp

# windowsApp
COPY ./Terraform/windowsApp/ec2Win.tf /temp/terraform/windowsApp
COPY ./Terraform/windowsApp/sqlWin.tf /temp/terraform/windowsApp

# msmq
COPY ./Terraform/msmq-s3/que.tf /temp/terraform/msmq
COPY ./Terraform/msmq-s3/s3.tf /temp/terraform/msmq

# return to temp workdir
WORKDIR /temp

ENTRYPOINT [ "./setup.sh" ]