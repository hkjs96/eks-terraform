# EKS 클러스터 데이터 소스 참조
data "aws_eks_cluster" "this" {
  name = var.cluster_name
}

# 클러스터 OIDC 인증서 데이터 가져오기
data "tls_certificate" "eks" {
  url = var.cluster_oidc_issuer
  
  # 데이터 소스에 대한 의존성 설정
  depends_on = [data.aws_eks_cluster.this]
}

# OIDC 제공자 생성
resource "aws_iam_openid_connect_provider" "eks" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks.certificates[0].sha1_fingerprint]
  url             = var.cluster_oidc_issuer

  tags = merge(
    var.tags,
    {
      "Name" = "${var.cluster_name}-oidc-provider"
    }
  )
  
  # TLS 인증서 데이터에 대한 의존성 설정
  depends_on = [data.tls_certificate.eks]
}