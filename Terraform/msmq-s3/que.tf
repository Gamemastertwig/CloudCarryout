provider "aws"{}

resource "aws_sqs_queue" "que"{
    name = "que"
    max_message_size = 1024
    message_retention_seconds = 60
    receive_wait_time_seconds = 3
}
