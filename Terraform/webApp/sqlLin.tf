resource "aws_db_instance" "webAppDb" {
    name = "webAppDb"
    allocated_storage = 10
    max_allocated_storage = 40
    storage_type = "gp2"
    engine = "mysql"
    engine_version = "5.7"
    instance_class = "db.t2.micro"
    username = "root"
    password = "123456789"
    multi_az = "false"
    backup_retention_period = 10

    vpc_security_group_ids = ["${aws_security_group.awdb_sec.id}"]
    parameter_group_name = "wadbpar"
    db_subnet_group_name = "wadbsub"

}

resource "aws_db_parameter_group" "wadbpar"{
    name = "wadbpar"
    family = "mysql5.7"
}

resource "aws_db_subnet_group" "wadbsub"{
    name = "wadbsub"
    subnet_ids = ["${aws_subnet.sub1.id}","${aws_subnet.sub2.id}"]
}

resource "aws_security_group" "awdb_sec" {
  vpc_id = "${aws_vpc.vpc.id}"
  description = "Allow traffic from ec2 intance and load balancer"

  //traffic access is currently allowed from ec2 and lb while I figure out how to route traffic
  ingress {
    description = "traffic from lv and ec2 instance"
    from_port   = 8080
    to_port     = 8080
    protocol =   "tcp"
    security_groups = ["${aws_security_group.lbGroup.id}","${aws_security_group.traffic.id}"]
  }

  //traffic egress
  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}