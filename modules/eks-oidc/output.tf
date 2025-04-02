output "oidc_provider_arn" {
  description = "EKS OIDC 제공자 ARN"
  value       = aws_iam_openid_connect_provider.eks.arn
}

output "oidc_provider_url" {
  description = "EKS OIDC 제공자 URL"
  value       = aws_iam_openid_connect_provider.eks.url
}