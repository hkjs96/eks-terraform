output "node_group_id" {
  description = "EKS 노드 그룹 ID"
  value       = aws_eks_node_group.this.id
}

output "node_group_arn" {
  description = "EKS 노드 그룹 ARN"
  value       = aws_eks_node_group.this.arn
}

output "node_group_status" {
  description = "EKS 노드 그룹 상태"
  value       = aws_eks_node_group.this.status
}

output "node_group_role_arn" {
  description = "EKS 노드 그룹 IAM 역할 ARN"
  value       = aws_iam_role.node_group.arn
}

output "node_group_role_name" {
  description = "EKS 노드 그룹 IAM 역할 이름"
  value       = aws_iam_role.node_group.name
}

output "launch_template_id" {
  description = "노드 그룹 시작 템플릿 ID"
  value       = aws_launch_template.node_group.id
}

output "launch_template_latest_version" {
  description = "노드 그룹 시작 템플릿 최신 버전"
  value       = aws_launch_template.node_group.latest_version
}

output "instance_profile_name" {
  description = "노드 인스턴스 프로파일 이름"
  value       = aws_iam_instance_profile.node_group.name
}

output "instance_profile_arn" {
  description = "노드 인스턴스 프로파일 ARN"
  value       = aws_iam_instance_profile.node_group.arn
}

output "autoscaling_group_names" {
  description = "노드 그룹의 오토스케일링 그룹 이름"
  value       = aws_eks_node_group.this.resources[0].autoscaling_groups[*].name
}