# === יצירת מדיניות אדמין למשתמש yakirpip ===
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

# === צירוף המדיניות למשתמש yakirpip (המשתמש שמריץ את Terraform) ===
resource "aws_iam_user_policy_attachment" "attach_admin_policy_yakirpip" {
  user       = "yakirpip"
  policy_arn = aws_iam_policy.terraform_admin_policy.arn
}
