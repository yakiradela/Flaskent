output "eks_cluster_name" {
  value = aws_eks_cluster.eks_cluster.name
}

output "eks_cluster_endpoint" {
  value = aws_eks_cluster.eks_cluster.endpoint
}

output "ecr_repository_url" {
  value = aws_ecr_repository.flask_app_ecr.repository_url
}

output "s3_bucket_name" {
  value = module.bootstrap.s3_bucket_name
}

output "dynamodb_table_name" {
  value = module.bootstrap.dynamodb_table_name
}

