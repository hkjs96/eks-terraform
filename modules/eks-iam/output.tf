output "ebs_csi_role_arn" {
  description = "EBS CSI 드라이버 IAM 역할 ARN"
  value       = aws_iam_role.ebs_csi_role.arn
}

output "lb_controller_role_arn" {
  description = "AWS Load Balancer Controller IAM 역할 ARN"
  value       = aws_iam_role.lb_controller_role.arn
}

output "cluster_autoscaler_role_arn" {
  description = "Cluster Autoscaler IAM 역할 ARN"
  value       = aws_iam_role.cluster_autoscaler_role.arn
}