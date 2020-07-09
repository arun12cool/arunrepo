resource "aws_s3_bucket" "b" {
  bucket = "screen-record"
  acl    = "private"

  tags = {
    Name        = "screen-record"
    Environment = "CI"
  }
}
