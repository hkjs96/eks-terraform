variable "region" {
  description = "AWS 리전"
  type        = string
  default     = "ap-northeast-2"
}

variable "project_name" {
  description = "프로젝트 이름"
  type        = string
}

variable "environment" {
  description = "환경 (dev, staging, production)"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR 블록"
  type        = string
}

variable "azs" {
  description = "가용 영역 목록"
  type        = list(string)
}

variable "private_subnets" {
  description = "프라이빗 서브넷 CIDR 목록"
  type        = list(string)
}

variable "public_subnets" {
  description = "퍼블릭 서브넷 CIDR 목록"
  type        = list(string)
}

variable "cluster_name" {
  description = "EKS 클러스터 이름"
  type        = string
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
  default     = {}
}
