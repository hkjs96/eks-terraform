# EKS 클러스터 데이터 소스 참조
data "aws_eks_cluster" "this" {
  name = var.cluster_name
}

# VPC 데이터 소스 참조
data "aws_vpc" "this" {
  id = var.vpc_id
}

# Amazon VPC CNI 애드온
resource "aws_eks_addon" "vpc_cni" {
  count = var.enable_vpc_cni ? 1 : 0
  
  cluster_name              = data.aws_eks_cluster.this.name
  addon_name                = "vpc-cni"
  addon_version             = var.vpc_cni_version
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"
  
  tags = var.tags
  
  # 노드 그룹 의존성 추가
  depends_on = [var.node_group_depends_on]
}

# CoreDNS 애드온
resource "aws_eks_addon" "coredns" {
  count = var.enable_coredns ? 1 : 0
  
  cluster_name               = data.aws_eks_cluster.this.name
  addon_name                 = "coredns"
  addon_version              = var.coredns_version
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"
  
  tags = var.tags
  
  # 노드 그룹 의존성 및 VPC CNI 애드온에 대한 의존성 추가
  depends_on = [var.node_group_depends_on, aws_eks_addon.vpc_cni]
}

# kube-proxy 애드온
resource "aws_eks_addon" "kube_proxy" {
  count = var.enable_kube_proxy ? 1 : 0
  
  cluster_name               = data.aws_eks_cluster.this.name
  addon_name                 = "kube-proxy"
  addon_version              = var.kube_proxy_version
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"
  
  tags = var.tags
  
  # 노드 그룹 의존성 및 VPC CNI 애드온에 대한 의존성 추가
  depends_on = [var.node_group_depends_on, aws_eks_addon.vpc_cni]
}

# EBS CSI 드라이버 애드온
resource "aws_eks_addon" "ebs_csi" {
  count = var.enable_ebs_csi ? 1 : 0
  
  cluster_name               = data.aws_eks_cluster.this.name
  addon_name                 = "aws-ebs-csi-driver"
  addon_version              = var.ebs_csi_version
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"
  
  # EBS CSI 컨트롤러 서비스 계정에 IRSA 사용
  service_account_role_arn = var.ebs_csi_role_arn
  
  tags = var.tags
  
  # 노드 그룹 의존성 및 CoreDNS, kube-proxy 애드온에 대한 의존성 추가
  depends_on = [
    var.node_group_depends_on, 
    aws_eks_addon.vpc_cni, 
    aws_eks_addon.coredns, 
    aws_eks_addon.kube_proxy
  ]
}

