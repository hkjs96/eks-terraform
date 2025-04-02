output "cluster_id" {
  description = "EKS 클러스터 ID"
  value       = aws_eks_cluster.this.id
}

output "cluster_arn" {
  description = "EKS 클러스터 ARN"
  value       = aws_eks_cluster.this.arn
}

output "cluster_endpoint" {
  description = "EKS 클러스터 엔드포인트"
  value       = aws_eks_cluster.this.endpoint
}

output "cluster_security_group_id" {
  description = "EKS 클러스터 보안 그룹 ID"
  value       = aws_eks_cluster.this.vpc_config[0].cluster_security_group_id
}

output "cluster_oidc_issuer" {
  description = "EKS 클러스터 OIDC 발급자 URL"
  value       = aws_eks_cluster.this.identity[0].oidc[0].issuer
}

output "cluster_certificate_authority_data" {
  description = "EKS 클러스터 CA 데이터"
  value       = aws_eks_cluster.this.certificate_authority[0].data
}

output "cluster_version" {
  description = "EKS 클러스터 쿠버네티스 버전"
  value       = aws_eks_cluster.this.version
}

output "cluster_iam_role_arn" {
  description = "EKS 클러스터 IAM 역할 ARN"
  value       = aws_iam_role.cluster.arn
}

output "kms_key_arn" {
  description = "EKS 클러스터 암호화에 사용되는 KMS 키 ARN"
  value       = aws_kms_key.eks.arn
}