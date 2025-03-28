output "cluster_id" {
  description = "EKS 클러스터 ID"
  value       = aws_eks_cluster.this.id
}

output "cluster_endpoint" {
  description = "EKS 클러스터 엔드포인트"
  value       = aws_eks_cluster.this.endpoint
}

output "cluster_security_group_id" {
  description = "EKS 클러스터 보안 그룹 ID"
  value       = aws_security_group.cluster.id
}

output "oidc_provider" {
  description = "EKS 클러스터의 OIDC 공급자 URL (https:// 제외)"
  value       = replace(aws_iam_openid_connect_provider.this.url, "https://", "")
}

output "oidc_provider_arn" {
  description = "EKS 클러스터의 OIDC 공급자 ARN"
  value       = aws_iam_openid_connect_provider.this.arn
}
