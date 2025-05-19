# ===== תפקידים ל-EKS Cluster =====
resource "aws_iam_role" "eks_cluster_role" {
  name = "eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [ {
      Effect = "Allow",
      Principal = {
        Service = "eks.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role_policy_attachment" "eks_service_policy" {
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
}

# ===== תפקידים ל-EKS Nodes =====
resource "aws_iam_role" "eks_node_role" {
  name = "eks-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "eks_worker_node_policy" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "eks_cni_policy" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "ecr_read_only" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

# ===== S3 Permissions for Terraform =====
resource "aws_iam_policy" "terraform_s3_access" {
  name = "TerraformS3Access"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Action = [
        "s3:CreateBucket",
        "s3:PutBucketAcl",
        "s3:GetBucketLocation",
        "s3:ListBucket",
        "s3:GetObject",
        "s3:PutObject",
        "s3:DeleteObject"
      ],
      Resource = [
        "arn:aws:s3:::*",
        "arn:aws:s3:::*/*"
      ]
    }]
  })
}

# ===== DynamoDB Permissions for Terraform =====
resource "aws_iam_policy" "terraform_dynamodb_access" {
  name = "TerraformDynamoDBAccess"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Action = [
        "dynamodb:CreateTable",
        "dynamodb:DescribeTable",
        "dynamodb:GetItem",
        "dynamodb:PutItem",
        "dynamodb:DeleteItem"
      ],
      Resource = "arn:aws:dynamodb:us-east-2:<ACCOUNT_ID>:table/terraform-locks"
    }]
  })
}

# ===== Allow PassRole so yakirpip can assign the roles to EKS =====
resource "aws_iam_policy" "passrole_policy" {
  name = "AllowPassRoleToEKS"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Action = "iam:PassRole",
      Resource = [
        aws_iam_role.eks_cluster_role.arn,
        aws_iam_role.eks_node_role.arn
      ]
    }]
  })
}

# ===== Attach all needed policies to the current user yakirpip =====
resource "aws_iam_user_policy_attachment" "attach_s3_policy" {
  user       = "yakirpip"
  policy_arn = aws_iam_policy.terraform_s3_access.arn
}

resource "aws_iam_user_policy_attachment" "attach_dynamodb_policy" {
  user       = "yakirpip"
  policy_arn = aws_iam_policy.terraform_dynamodb_access.arn
}

resource "aws_iam_user_policy_attachment" "attach_passrole_policy" {
  user       = "yakirpip"
  policy_arn = aws_iam_policy.passrole_policy.arn
}

