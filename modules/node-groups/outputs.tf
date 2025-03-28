output "node_group_arn" {
  description = "EKS 노드 그룹 ARN"
  value       = aws_eks_node_group.this.arn
}

output "node_group_id" {
  description = "EKS 노드 그룹 ID"
  value       = aws_eks_node_group.this.id
}

output "node_group_status" {
  description = "EKS 노드 그룹 상태"
  value       = aws_eks_node_group.this.status
}
