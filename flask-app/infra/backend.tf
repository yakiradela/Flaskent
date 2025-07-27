
terraform {
  backend "s3" {
    bucket         = "terraform-state--bucketxyz123"
    key            = "infra/terraform.tfstate"
    region         = "us-east-2"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
