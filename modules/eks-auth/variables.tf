variable "cluster_endpoint" {
  description = "EKS 클러스터 엔드포인트"
  type        = string
}

variable "cluster_ca_certificate" {
  description = "EKS 클러스터 CA 인증서 데이터"
  type        = string
}

variable "cluster_id" {
  description = "EKS 클러스터 ID"
  type        = string
}


variable "node_group_role_arn" {
  description = "EKS 노드 그룹 IAM 역할 ARN"
  type        = string
}

variable "depends_on_resources" {
  description = "이 모듈이 의존하는 리소스 목록"
  type        = any
  default     = null
}

variable "extra_user_arn" {
  description = "추가 클러스터 접근을 위한 IAM 사용자 ARN"
  type        = string
  default     = "arn:aws:iam::560412178918:user/bakjisu"
}

variable "extra_username" {
  description = "추가 클러스터 접근을 위한 IAM 사용자 이름"
  type        = string
  default     = "bakjisu"
}
