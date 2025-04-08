# VPC 데이터 소스 참조 추가
data "aws_vpc" "this" {
  id = var.vpc_id
}

# 서브넷 데이터 소스 참조 추가
data "aws_subnet" "private" {
  count = length(var.subnet_ids)
  id    = var.subnet_ids[count.index]
}

# KMS 키 생성 (시크릿 암호화용)
resource "aws_kms_key" "eks" {
  description             = "EKS Secret Encryption Key for ${var.cluster_name}"
  deletion_window_in_days = 7
  enable_key_rotation     = true
  tags                    = var.tags
}

# EKS 클러스터 보안 그룹
## https://docs.aws.amazon.com/ko_kr/eks/latest/userguide/sec-group-reqs.html
resource "aws_security_group" "cluster" {
  name        = "${var.cluster_name}-cluster-sg"
  description = "Cluster security group for ${var.cluster_name} EKS cluster"
  vpc_id      = data.aws_vpc.this.id  # 데이터 소스 참조로 변경

  tags = merge(
    var.tags,
    # {
    #   "Name" = "${var.cluster_name}-cluster-sg",
    # }
  )
}

# 클러스터 보안 그룹 인바운드 규칙
resource "aws_security_group_rule" "cluster_ingress_self" {
  description              = "Allow communication within the cluster security group"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "tcp"
  security_group_id        = aws_security_group.cluster.id
  source_security_group_id = aws_security_group.cluster.id
  type                     = "ingress"
  
  depends_on = [aws_security_group.cluster]
}

# 클러스터 보안 그룹 아웃바운드 규칙
resource "aws_security_group_rule" "cluster_egress_internet" {
  description       = "Allow cluster egress to internet"
  from_port         = 0
  to_port           = 65535
  protocol          = "all"
  security_group_id = aws_security_group.cluster.id
  cidr_blocks       = ["0.0.0.0/0"]
  type              = "egress"
  
  depends_on = [aws_security_group.cluster]
}

# EKS 클러스터 IAM 역할
resource "aws_iam_role" "cluster" {
  name = "${var.cluster_name}-cluster-role"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "eks.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })

  tags = var.tags
}

# EKS 클러스터 IAM 정책 연결
resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.cluster.name
  
  depends_on = [aws_iam_role.cluster]
}

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.cluster.name
  
  depends_on = [aws_iam_role.cluster]
}

# EKS 클러스터 생성
resource "aws_eks_cluster" "this" {
  name     = var.cluster_name
  role_arn = aws_iam_role.cluster.arn
  version  = var.kubernetes_version

  vpc_config {
    subnet_ids              = var.subnet_ids  # 변수로 유지 (데이터 소스는 이미 상위에서 참조)
    endpoint_private_access = var.endpoint_private_access
    endpoint_public_access  = var.endpoint_public_access
    public_access_cidrs     = var.endpoint_public_access_cidrs
    security_group_ids      = [aws_security_group.cluster.id]
  }

  encryption_config {
    provider {
      key_arn = aws_kms_key.eks.arn
    }
    resources = ["secrets"]
  }

  # 클러스터 로깅 설정
  enabled_cluster_log_types = var.enabled_cluster_log_types

  # 접근 설정
  access_config {
    authentication_mode                         = "API_AND_CONFIG_MAP"
    bootstrap_cluster_creator_admin_permissions = true
  }

  tags = merge(
    var.tags,
    {
      "Name" = var.cluster_name
    }
  )

  # 업그레이드 정책 설정
  upgrade_policy {
    support_type = "EXTENDED"
  }

  # IAM 역할이 먼저 생성되도록 설정 - 의존성 명시적 추가
  depends_on = [
    aws_iam_role_policy_attachment.cluster_AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.cluster_AmazonEKSVPCResourceController,
    aws_security_group.cluster,
    aws_kms_key.eks
  ]

  # 생성 전 파괴 방지 (중요 클러스터)
  lifecycle {
    create_before_destroy = true
  }
}