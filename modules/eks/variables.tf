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
  description = "서브넷 ID 목록"
  type        = list(string)
}

variable "endpoint_private_access" {
  description = "프라이빗 API 엔드포인트 활성화 여부"
  type        = bool
  default     = true
}

variable "endpoint_public_access" {
  description = "퍼블릭 API 엔드포인트 활성화 여부"
  type        = bool
  default     = true
}

variable "kms_key_arn" {
  description = "암호화에 사용할 KMS 키 ARN"
  type        = string
}

variable "tags" {
  description = "리소스에 적용할 태그"
  type        = map(string)
  default     = {}
}
