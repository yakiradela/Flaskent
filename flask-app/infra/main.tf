# יצירת הדלי תחילה
resource "aws_s3_bucket" "terraform_state" {
  bucket = var.bucket_name
  acl    = "private"
}

# VPC
resource "aws_vpc" "main_vpc" {
  cidr_block = var.vpc_cidr
}

# תת-רשת ציבורית
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = "us-east-2a"
  map_public_ip_on_launch = true
  tags = {
    Name = "public-subnet"
  }
}

# תת-רשת פרטית
resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = var.private_subnet_cidr
  availability_zone = "us-east-2b"
  tags = {
    Name = "private-subnet"
  }
}

# קלאסטר EKS
resource "aws_eks_cluster" "eks_cluster" {
  name     = var.eks_cluster_name
  role_arn = "arn:aws:iam::557690607676:role/eksClusterRole"  # להוסיף ידנית הרשאות

  vpc_config {
    subnet_ids = [aws_subnet.public_subnet.id, aws_subnet.private_subnet.id]
  }
}

# Node Group ציבורי
resource "aws_eks_node_group" "node_group_public" {
  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_group_name = "node-group-public"
  node_role_arn   = "arn:aws:iam::557690607676:role/eksNodeRole"
  subnet_ids      = [aws_subnet.public_subnet.id]

  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 1
  }
}

# Node Group פרטי
resource "aws_eks_node_group" "node_group_private" {
  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_group_name = "node-group-private"
  node_role_arn   = "arn:aws:iam::557690607676:role/eksNodeRole"
  subnet_ids      = [aws_subnet.private_subnet.id]

  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 1
  }
}

# מאגר ECR
resource "aws_ecr_repository" "flask_app_ecr" {
  name = "flask-app-repository"
}
