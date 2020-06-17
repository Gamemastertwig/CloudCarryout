provider "aws" {}

resource "aws_instance" "winApp {
    ami = "ami-0e84e211558a022c0"
    instance_type = "t2.micro"

    subnet_id = "${aws_subnet.winsub.id}"
    vpc_security_group_ids = ["${aws_security_group.winsec.id}"]
}

resource "aws_security_group" "winsec" {
  vpc_id = "${aws_vpc.winvpc.id}"
  description = "Allow traffic on port 80 and ssh on 22"

  //user access
  ingress {
    description = "Accessing the app"
    from_port   = 9000
    to_port     = 8000
    protocol =   "tcp"
    cidr_blocks =  ["0.0.0.0/0"]
  }

    //ssh ingress
    ingress {
    description = "ssh access"
    from_port   = 22
    to_port     = 22
    protocol =   "tcp"

    cidr_blocks =  ["0.0.0.0/0"]
  }

  //traffic egress
  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}

output "instance_ip" {
    value=aws_instance.web_server.public_ip
}

resource "aws_vpc" "winvpc" {
  cidr_block = "170.170.0.0/16"
  instance_tenancy = "default"

  tags = {
    name = "winvpc"
  }
}

resource "aws_internet_gateway" "wingw"{
  vpc_id = "${aws_vpc.winvpc.id}"
}

resource "aws_subnet" "winsub"{
  vpc_id = "${aws_vpc.winvpc.id}"
  cidr_block = "170.170.2.0/24"
  availability_zone = "us-east-2b"

  tags = {
    name = "winsub"
  }
}