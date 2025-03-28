output "cluster_id" {
  description = "EKS 클러스터 ID"
  value       = module.eks.cluster_id
}

output "cluster_endpoint" {
  description = "EKS 클러스터 엔드포인트"
  value       = module.eks.cluster_endpoint
}

output "cluster_security_group_id" {
  description = "EKS 클러스터 보안 그룹 ID"
  value       = module.eks.cluster_security_group_id
}

output "oidc_provider" {
  description = "EKS 클러스터의 OIDC 공급자 URL"
  value       = module.eks.oidc_provider
}

output "oidc_provider_arn" {
  description = "EKS 클러스터의 OIDC 공급자 ARN"
  value       = module.eks.oidc_provider_arn
}

output "kubectl_config_command" {
  description = "kubectl 구성 명령어"
  value       = "aws eks update-kubeconfig --name ${var.cluster_name} --region ${var.region}"
}

output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "private_subnets" {
  description = "프라이빗 서브넷 ID 목록"
  value       = module.vpc.private_subnets
}

output "public_subnets" {
  description = "퍼블릭 서브넷 ID 목록"
  value       = module.vpc.public_subnets
}

output "ebs_csi_role_arn" {
  description = "EBS CSI 드라이버용 IAM 역할 ARN"
  value       = aws_iam_role.ebs_csi_role.arn
}

output "lb_controller_role_arn" {
  description = "AWS Load Balancer Controller용 IAM 역할 ARN"
  value       = aws_iam_role.lb_controller_role.arn
}
