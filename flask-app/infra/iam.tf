
# === יצירת מדיניות אדמין למשתמש yakirpip ===
resource "aws_iam_policy" "terraform_admin_policy" {
  name = "TerraformAdminPolicy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect   = "Allow",
      Action   = [
        "iam:*",
        "ec2:*",
        "s3:*",
        "ecr:*",
        "eks:*",
        "dynamodb:*",
        "sts:AssumeRole"
      ],
      Resource = "*"
    }]
  })
}

# === צירוף המדיניות למשתמש yakirpip (המשתמש שמריץ את Terraform) ===
resource "aws_iam_user_policy_attachment" "attach_admin_policy_yakirpip" {
  user       = "yakirpip"
  policy_arn = aws_iam_policy.terraform_admin_policy.arn
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
  node_role_arn   = aws_iam_role.eks_node_role.arn  # שימוש בתפקיד המוגדר
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

# === יצירת IAM Role עבור EKS Node Group ===
resource "aws_iam_role" "eks_node_role" {
  name = "eksNodeRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Effect    = "Allow"
        Sid       = ""
      },
    ]
  })

  tags = {
    Name = "eksNodeRole"
  }
}

# צירוף מדיניות ל- IAM Role של ה-Node Group
resource "aws_iam_role_policy_attachment" "eks_node_policy" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "eks_vpc_policy" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonVPCFullAccess"
}
