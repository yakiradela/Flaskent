resource "aws_s3_bucket" "terraform_state" {
  bucket = "terraform-state--bucketxyz123"
  region = "us-east-2"
}

# acl הוא deprecated ולכן אנחנו משתמשים בaws_s3_bucket_acl
resource "aws_s3_bucket_acl" "terraform_state_acl" {
  bucket = aws_s3_bucket.terraform_state.id
  acl    = "private"
}

resource "aws_dynamodb_table" "terraform_locks" {
  name           = "terraform-locks"
  hash_key       = "LockID"
  read_capacity  = 5
  write_capacity = 5

  attribute {
    name = "LockID"
    type = "S"
  }

  billing_mode = "PROVISIONED"
}

