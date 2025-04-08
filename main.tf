provider "aws" {
  region = "ap-northeast-2" # 고정 리전 설정
}

# 1. VPC 모듈 호출
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name                 = "${var.project_name}-vpc"
  cidr                 = var.vpc_cidr
  azs                  = var.azs
  private_subnets      = var.private_subnets
  public_subnets       = var.public_subnets
  enable_nat_gateway   = true
  single_nat_gateway   = var.environment != "production"
  enable_dns_hostnames = true

  tags = var.tags

  public_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                    = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"           = "1"
  }
}

# VPC 생성 후 데이터 소스로 참조하기 위한 리소스 ID 출력
resource "terraform_data" "vpc_ready" {
  depends_on = [module.vpc]

  # VPC가 완전히 생성된 것을 알리는 트리거
  triggers_replace = {
    vpc_id = module.vpc.vpc_id
  }
}

# 2. EKS 클러스터 모듈 호출
module "eks_cluster" {
  source = "./modules/eks-cluster"

  cluster_name       = var.cluster_name
  kubernetes_version = var.cluster_version

  # 데이터 소스 대신 직접 참조하지만, 의존성 명시
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  endpoint_private_access      = var.cluster_endpoint_private_access
  endpoint_public_access       = var.cluster_endpoint_public_access
  endpoint_public_access_cidrs = var.cluster_endpoint_public_access_cidrs
  enabled_cluster_log_types = [
    "api",
    "audit",
    "authenticator",
    "controllerManager",
    "scheduler"
  ]
  tags = var.tags

  # VPC 모듈에 대한 명시적 의존성 설정
  depends_on = [terraform_data.vpc_ready]
}

# 3. OIDC 제공자 모듈 호출 (신규)
module "eks_oidc" {
  source = "./modules/eks-oidc"

  cluster_name        = var.cluster_name
  cluster_oidc_issuer = module.eks_cluster.cluster_oidc_issuer
  tags                = var.tags

  # EKS 클러스터에 대한 명시적 의존성 설정 
  depends_on = [module.eks_cluster]
}

# 4. IAM 역할 모듈 호출 (신규)
module "eks_iam" {
  source = "./modules/eks-iam"

  cluster_name      = var.cluster_name
  oidc_provider_arn = module.eks_oidc.oidc_provider_arn
  oidc_provider_url = module.eks_oidc.oidc_provider_url
  tags              = var.tags

  # OIDC 공급자에 대한 명시적 의존성 설정
  depends_on = [module.eks_oidc]
}

# 5. 노드 그룹 모듈 호출
# 5. 노드 그룹 모듈 호출 - 클러스터 보안 그룹 ID와 환경 변수 추가
module "eks_node_groups" {
  source = "./modules/node-groups"

  cluster_name              = var.cluster_name
  cluster_endpoint          = module.eks_cluster.cluster_endpoint
  cluster_auth_base64       = module.eks_cluster.cluster_certificate_authority_data
  cluster_security_group_id = module.eks_cluster.cluster_security_group_id
  environment               = var.environment
  node_group_name           = "${var.cluster_name}-nodes"

  # 서브넷 ID 전달
  subnet_ids = module.vpc.private_subnets # 프라이빗 서브넷

  disk_size        = 100
  instance_types   = var.environment == "production" ? ["m5.2xlarge"] : ["t3.medium"]
  capacity_type    = var.environment == "production" ? "ON_DEMAND" : "SPOT"
  desired_capacity = var.environment == "production" ? 5 : 3
  min_capacity     = var.environment == "production" ? 3 : 2
  max_capacity     = var.environment == "production" ? 10 : 5
  max_unavailable  = 1
  node_labels = {
    "role"        = "worker"
    "environment" = var.environment
  }
  node_taints = []
  tags        = var.tags

  # 클러스터가 완전히 생성된 후에 노드 그룹 생성을 보장하기 위한 의존성 설정
  depends_on = [
    module.eks_cluster,
    module.eks_oidc,
    module.eks_iam
  ]
}

# 노드 그룹 생성 후 데이터 소스로 참조하기 위한 리소스 ID 출력
resource "terraform_data" "node_groups_ready" {
  depends_on = [module.eks_node_groups]

  # 노드 그룹이 완전히 생성된 것을 알리는 트리거
  triggers_replace = {
    node_group_id = module.eks_node_groups.node_group_id
  }
}

# 6. EKS 애드온 모듈 호출 - provider 구성이 제거된 모듈 사용
module "eks_addons" {
  source = "./modules/eks-addons"

  cluster_name           = var.cluster_name
  ebs_csi_role_arn       = module.eks_iam.ebs_csi_role_arn
  lb_controller_role_arn = module.eks_iam.lb_controller_role_arn
  node_group_depends_on  = module.eks_node_groups.node_group_id

  # VPC ID 전달
  vpc_id = module.vpc.vpc_id

  # 애드온 설정
  enable_vpc_cni    = true
  enable_coredns    = true
  enable_kube_proxy = true
  enable_ebs_csi    = true

  tags = var.tags

  # 노드 그룹 완료 트리거에 의존 - 모듈 내부에 provider가 없으므로 depends_on 사용 가능
  depends_on = [terraform_data.node_groups_ready]
}

# EKS Auth 모듈 호출
module "eks_auth" {
  source                 = "./modules/eks-auth"
  cluster_endpoint       = module.eks_cluster.cluster_endpoint
  cluster_ca_certificate = module.eks_cluster.cluster_certificate_authority_data
  cluster_id             = module.eks_cluster.cluster_id
  node_group_role_arn    = module.eks_node_groups.node_group_role_arn
  depends_on_resources = {
    cluster_id    = module.eks_cluster.cluster_id
    node_group_id = module.eks_node_groups.node_group_id
  }
}
