provider "aws" {}

resource "aws_instance" "web_server" {
    //east1 ami
    ami = "ami-09d95fab7fff3776c"
    //east2 ami
    //ami = "ami-0e84e211558a022c0"
    instance_type = "t2.micro"

    subnet_id = "${aws_subnet.sub1.id}"
    vpc_security_group_ids = ["${aws_security_group.lbGroup.id}"]
    associate_public_ip_address = true

    //key_name = "temp"

    lifecycle {
      create_before_destroy = true
    }

}

resource "aws_security_group" "lbGroup" {
  vpc_id = "${aws_vpc.vpc.id}"
  description = "Allow traffic on port 80 and ssh on 22"

  //traffic access
  ingress {
    description = "http from lb"
    from_port   = 80
    to_port     = 80
    protocol =   "tcp"
    security_groups = ["${aws_security_group.traffic.id}"]

    //cidr_blocks =  [aws_vpc.vpc.cidr_block]
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
