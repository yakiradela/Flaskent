# יצירת משתמש IAM חדש (לצורך הדגמה – זה לא המשתמש שמריץ את Terraform בפועל)
resource "aws_iam_user" "yakirpip" {
  name = "yakirpip"
}

# === תפקידים ל-EKS Cluster ול-Node Group ===
resource "aws_iam_role" "eks_cluster_role" {
  name = "eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
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

# === מדיניות מותאמות אישית לגישה ל-S3 ול-DynamoDB ===
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
      Resource = "arn:aws:dynamodb:us-east-2:557690607676:table/terraform-locks"
    }]
  })
}

# === צירוף המדיניות למשתמש yakir ===
resource "aws_iam_user_policy_attachment" "attach_s3_policy" {
  user       = aws_iam_user.yakir.name 
  policy_arn = aws_iam_policy.terraform_s3_access.arn
}

resource "aws_iam_user_policy_attachment" "attach_dynamodb_policy" {
  user       = aws_iam_user.yakir.name  
  policy_arn = aws_iam_policy.terraform_dynamodb_access.arn
}

# === יצירת מדיניות אדמין למשתמש שמריץ את Terraform (yakirpip) ===
resource "aws_iam_policy" "terraform_admin_policy" {
  name = "TerraformAdminPolicy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Action = [
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

# ✅ צירוף המדיניות למשתמש yakirpip (במידה ויש הרשאות לעשות זאת)
resource "aws_iam_user" "yakirpip" {
  name = "yakirpip" # 🔧 נוספה שורה זו כדי לאפשר הצמדה למשתמש קיים או חדש
  force_destroy = true
}

resource "aws_iam_user_policy_attachment" "attach_admin_policy_yakirpip" {
  user       = aws_iam_user.yakirpip.name # ✅ נוספה בלוק זה
  policy_arn = aws_iam_policy.terraform_admin_policy.arn
}
