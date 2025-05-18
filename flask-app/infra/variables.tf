variable "bucket_name" {
  description = "S3 bucket name for Terraform state"
  type        = string
  default     = "terraform-state--bucketxyz123"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  default = "10.0.1.0/24"
}

variable "private_subnet_cidr" {
  default = "10.0.2.0/24"
}

variable "eks_cluster_name" {
  default = "eks-cluster"
}
