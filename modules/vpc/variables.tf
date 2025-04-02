variable "region" {
  description = "AWS 리전"
  type        = string
  default     = "ap-northeast-2"
}

variable "project_name" {
  description = "프로젝트 이름"
  type        = string
  default     = "eks-demo"
}

variable "environment" {
  description = "환경 (dev, staging, production)"
  type        = string
  default     = "dev"
}

variable "vpc_cidr" {
  description = "VPC CIDR 블록"
  type        = string
  default     = "10.0.0.0/16"
}

variable "azs" {
  description = "가용 영역 목록"
  type        = list(string)
  default     = ["ap-northeast-2a", "ap-northeast-2c"]
}

variable "private_subnets" {
  description = "프라이빗 서브넷 CIDR 목록"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "public_subnets" {
  description = "퍼블릭 서브넷 CIDR 목록"
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
}

variable "cluster_name" {
  description = "EKS 클러스터 이름"
  type        = string
  default     = "eks-demo-cluster"
}

variable "cluster_version" {
  description = "쿠버네티스 버전"
  type        = string
  default     = "1.29"
}

variable "cluster_endpoint_private_access" {
  description = "EKS 클러스터 프라이빗 엔드포인트 활성화 여부"
  type        = bool
  default     = true
}

variable "cluster_endpoint_public_access" {
  description = "EKS 클러스터 퍼블릭 엔드포인트 활성화 여부"
  type        = bool
  default     = true
}

variable "cluster_endpoint_public_access_cidrs" {
  description = "EKS 클러스터 퍼블릭 엔드포인트에 접근 가능한 CIDR 목록"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "tags" {
  description = "리소스에 적용할 태그"
  type        = map(string)
  default     = {
    "Environment" = "dev"
    "ManagedBy"   = "terraform"
    "Owner"       = "devops-team"
    "Project"     = "eks-demo"
  }
}