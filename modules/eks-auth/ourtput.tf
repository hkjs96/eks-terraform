output "aws_auth_configmap_id" {
  description = "Kubernetes aws-auth ConfigMap ID"
  value       = kubernetes_config_map.aws_auth.id
}

output "cluster_role_binding_id" {
  description = "Kubernetes ClusterRoleBinding ID"
  value       = kubernetes_cluster_role_binding.admin.id
}