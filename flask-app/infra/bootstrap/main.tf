
# provider "aws" {
  region = "us-east-2"
  }

# resource "aws_s3_bucket" "terraform_state" {
  bucket = "terraform-state--bucketxyz123"
  acl    = "private"
  }

# resource "aws_dynamodb_table" "terraform_locks" {
  name         = "terraform-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
    }
  }
