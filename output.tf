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

output "cluster_id" {
  description = "EKS 클러스터 ID"
  value       = module.eks_cluster.cluster_id
}

output "cluster_endpoint" {
  description = "EKS 클러스터 엔드포인트"
  value       = module.eks_cluster.cluster_endpoint
}

output "cluster_security_group_id" {
  description = "EKS 클러스터 보안 그룹 ID"
  value       = module.eks_cluster.cluster_security_group_id
}

output "cluster_version" {
  description = "EKS 클러스터 쿠버네티스 버전"
  value       = module.eks_cluster.cluster_version
}

output "oidc_provider_arn" {
  description = "EKS OIDC 제공자 ARN"
  value       = module.eks_oidc.oidc_provider_arn
}

output "node_group_id" {
  description = "EKS 노드 그룹 ID"
  value       = module.eks_node_groups.node_group_id
}

output "node_group_status" {
  description = "EKS 노드 그룹 상태"
  value       = module.eks_node_groups.node_group_status
}

output "ebs_csi_role_arn" {
  description = "EBS CSI 드라이버 IAM 역할 ARN"
  value       = module.eks_iam.ebs_csi_role_arn
}

output "lb_controller_role_arn" {
  description = "Load Balancer Controller IAM 역할 ARN"
  value       = module.eks_iam.lb_controller_role_arn
}

output "kubectl_config_command" {
  description = "kubectl 구성 명령어"
  value       = "aws eks update-kubeconfig --name ${var.cluster_name} --region ${var.region}"
}