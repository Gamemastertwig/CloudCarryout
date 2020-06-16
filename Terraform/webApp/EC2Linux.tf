provider "aws" {}

resource "aws_ami_copy" "linux" {
  name              = "CloudCarryout_linux_ami"
  description       = "A copy of ami-0e34e7b9ca0ace12d"
  source_ami_id     = "ami-0e34e7b9ca0ace12d"
  source_ami_region = "us-west-2"

  tags = {
    Name = "CloudCarryout"
  }
}

resource "aws_instance" "web_server" {
    ami = "${aws_ami_copy.linux.id}"
    instance_type = "t2.micro"

    
}

output "instance_ip" {
    value=aws_instance.web_server.public_ip
}