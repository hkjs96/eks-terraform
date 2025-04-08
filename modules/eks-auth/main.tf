data "aws_eks_cluster_auth" "cluster" {
  name = var.cluster_id
}

# 현재 AWS 호출자 아이덴티티 가져오기
data "aws_caller_identity" "current" {}

# Kubernetes 프로바이더 구성 - main.tf에서 구성된 것을 사용합니다.

# Kubernetes configmap을 생성하여 AWS IAM 사용자와 역할에 클러스터 액세스 권한 부여
resource "kubernetes_config_map" "aws_auth" {
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  data = {
    mapRoles = yamlencode([
      {
        rolearn  = var.node_group_role_arn
        username = "system:node:{{EC2PrivateDNSName}}"
        groups   = ["system:bootstrappers", "system:nodes"]
      },
      # 추가 역할을 여기에 넣을 수 있습니다.
    ])

    mapUsers = yamlencode([
      {
        userarn  = data.aws_caller_identity.current.arn
        username = data.aws_caller_identity.current.arn
        groups   = ["system:masters"]
      },
      # 추가 사용자를 여기에 넣을 수 있습니다.
      {
        userarn  = var.extra_user_arn
        username = var.extra_username
        groups   = ["system:masters"]
      }
    ])
  }
}

# 클러스터 관리자 역할 바인딩 생성
resource "kubernetes_cluster_role_binding" "admin" {
  metadata {
    name = "eks-console-admin"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }
  subject {
    kind      = "User"
    name      = data.aws_caller_identity.current.arn
    api_group = "rbac.authorization.k8s.io"
  }

  depends_on = [
    kubernetes_config_map.aws_auth
  ]
}
