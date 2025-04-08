# Kubernetes 프로바이더 구성 - EKS 클러스터의 정보를 사용하여 설정
provider "kubernetes" {
  host                   = var.cluster_endpoint
  cluster_ca_certificate = base64decode(var.cluster_ca_certificate)
  token                  = data.aws_eks_cluster_auth.cluster.token
}
