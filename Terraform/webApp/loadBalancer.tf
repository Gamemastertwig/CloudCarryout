resource "aws_vpc" "vpc" {
  cidr_block = "170.170.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "vpc"
  }
}

resource "aws_subnet" "main"
resource "aws_lb" "webAppLb"{
  name = "webAppLb"
  internal = false
  load_balancer_type = "application"
  security_groups = ["${aws_security_group.traffic.name}"]
  subnets = []
}

resource "aws_lb_target_group" "ec2Target"{
    name = "ec2Target"
    port = "80"
    protocol = "HTTP"
    vpc_id = "${aws_default_vpc.cloud.id}"
}

resource "aws_lb_target_group_attachment" "ec2Attachment" {
    target_group_arn = "${aws_lb_target_group.ec2Target.arn}"
    target_id = "${aws_instance.web_server.id}"
    port = 80
}

resource "aws_lb_listener" "appListener"{
  load_balancer_arn = "${aws_lb.webAppLb.arn}"
  port = 80
  protocol = "HTTP"

  default_action {
    type = "forward"
    target_group_arn = "${aws_lb_target_group.ec2Target.arn}"
  }
}

resource "aws_security_group" "traffic" {
  description = "Allow traffic on port 80"

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


