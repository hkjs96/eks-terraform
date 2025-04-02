variable "cluster_name" {
  description = "EKS 클러스터 이름"
  type        = string
}

variable "kubernetes_version" {
  description = "쿠버네티스 버전"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "subnet_ids" {
  description = "EKS 클러스터가 사용할 서브넷 ID 목록"
  type        = list(string)
}

variable "endpoint_private_access" {
  description = "EKS API 서버에 대한 프라이빗 엔드포인트 활성화 여부"
  type        = bool
  default     = true
}

variable "endpoint_public_access" {
  description = "EKS API 서버에 대한 퍼블릭 엔드포인트 활성화 여부"
  type        = bool
  default     = true
}

variable "endpoint_public_access_cidrs" {
  description = "EKS API 서버 퍼블릭 엔드포인트에 접근 가능한 CIDR 블록 목록"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "enabled_cluster_log_types" {
  description = "활성화할 EKS 클러스터 로그 유형 목록"
  type        = list(string)
  default     = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
}

variable "tags" {
  description = "리소스에 적용할 태그"
  type        = map(string)
  default     = {}
}