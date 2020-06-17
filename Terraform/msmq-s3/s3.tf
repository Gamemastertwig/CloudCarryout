resource "aws_s3_bucket" "quebucket" {
    bucket_prefix = "quebucket-"
    acl = "private"

    tags = {
        name = "quebucket"
    }
}