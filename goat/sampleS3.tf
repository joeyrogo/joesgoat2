terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  alias   = "user"
  region  = var.region
  profile = var.profile
}
resource "aws_s3_bucket" "example" {
  provider      = aws.user
  bucket        = var.bucket_name
  acl           = var.acl_value
  force_destroy = "false"           # Will prevent destruction of bucket with contents inside
}


resource "aws_s3_bucket_versioning" "example" {
  bucket = aws_s3_bucket.example.id

  versioning_configuration {
    status = "Enabled"
  }
}



resource "aws_s3_bucket" "example_log_bucket" {
  bucket = "example-log-bucket"
}

resource "aws_s3_bucket_logging" "example" {
  bucket = aws_s3_bucket.example.id

  target_bucket = aws_s3_bucket.example_log_bucket.id
  target_prefix = "log/"
}

resource "aws_s3_bucket_object" "object2" {
  for_each = fileset("myfiles/", "*")
  bucket   = aws_s3_bucket.example.bucket
  key      = "new_objects"
  source   = "myfiles/${each.value}"
  etag     = filemd5("myfiles/${each.value}")
}
