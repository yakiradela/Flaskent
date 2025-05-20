
output "s3_bucket_name" {
  value = module.bootstrap.s3_bucket_name
}

output "dynamodb_table_name" {
  value = module.bootstrap.dynamodb_table_name
}
