terraform {
  backend "s3" {
    bucket         = "terraform-state--bucketxyz123"
    key            = "eks/terraform.tfstate"
    region         = "us-east-2"
    encrypt        = true
  }
}
