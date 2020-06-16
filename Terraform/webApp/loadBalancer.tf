resource "aws_lb" "webAppLb"{
  name = "webAppLb"
  internal = false
  load_balancer_type = "application"
  security_groups = 
}

resource "aws_lb_target_group" "ec2Target"{
    name = "ec2Target"
    port = "80"
    protocol = "HTTP"
    vpc_id = "${aws_defaul_vpc.vpc.id}"
}

resource "aws_lb_target_group_attachment" "ec2Attachment" {
    target_group_arn = "${aws_lb_target_group.ec2Target.arn}"
    target_id = "$aws_instance.web_server.id"
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

resource "aws_default_vpc" "vpc" {
  tags = {
    Name = "vpc"
  }
}
