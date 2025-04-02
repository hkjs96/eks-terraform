output "vpc_cni_addon_id" {
  description = "VPC CNI 애드온 ID"
  value       = var.enable_vpc_cni ? aws_eks_addon.vpc_cni[0].id : null
}

output "coredns_addon_id" {
  description = "CoreDNS 애드온 ID"
  value       = var.enable_coredns ? aws_eks_addon.coredns[0].id : null
}

output "kube_proxy_addon_id" {
  description = "kube-proxy 애드온 ID"
  value       = var.enable_kube_proxy ? aws_eks_addon.kube_proxy[0].id : null
}

output "ebs_csi_addon_id" {
  description = "EBS CSI 드라이버 애드온 ID"
  value       = var.enable_ebs_csi ? aws_eks_addon.ebs_csi[0].id : null
}
