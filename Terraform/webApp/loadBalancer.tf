resource "aws_lb" "webAppLb"{
  name = "webAppLb"
  internal = false
  load_balancer_type = "application"
  security_groups = ["${aws_security_group.traffic.id}"]
  subnets = ["${aws_subnet.sub1.id}","${aws_subnet.sub2.id}"]
}

resource "aws_vpc" "vpc" {
  cidr_block = "170.170.0.0/16"
  instance_tenancy = "default"

  tags = {
    name = "vpc"
  }
}

resource "aws_internet_gateway" "appgw"{
  vpc_id = "${aws_vpc.vpc.id}"
  tags = {
    name = "appgw"
  }
}

resource "aws_subnet" "sub1"{
  vpc_id = "${aws_vpc.vpc.id}"
  cidr_block = "170.170.2.0/24"
  availability_zone = "us-east-2b"

  tags = {
    name = "sub1"
  }
}

resource "aws_subnet" "sub2"{
  vpc_id = "${aws_vpc.vpc.id}"
  cidr_block = "170.170.1.0/24"
  availability_zone = "us-east-2c"

  tags = {
    name = "sub2"
  }
}


resource "aws_lb_target_group" "CloudCarryoutEc2Lin"{
    name = "ec2Target"
    port = "80"
    protocol = "HTTP"
    vpc_id = "${aws_vpc.vpc.id}"
}

resource "aws_lb_target_group_attachment" "ec2Attachment" {
    target_group_arn = "${aws_lb_target_group.CloudCarryoutEc2Lin.arn}"
    target_id = "${aws_instance.web_server.id}"
    port = 80
}

resource "aws_lb_listener" "appListener"{
  load_balancer_arn = "${aws_lb.webAppLb.arn}"
  port = 80
  protocol = "HTTP"

  default_action {
    type = "forward"
    target_group_arn = "${aws_lb_target_group.CloudCarryoutEc2Lin.arn}"
  }
}

resource "aws_security_group" "traffic" {
  description = "Allow traffic on port 80"
    vpc_id = "${aws_vpc.vpc.id}"


  ingress {
    from_port   = 0 
    to_port     = 0
    protocol =   "-1"

    cidr_blocks =  ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}

output "dns_name" {
    value=aws_lb.webAppLb.dns_name
}


