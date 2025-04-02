variable "cluster_name" {
  description = "EKS 클러스터 이름"
  type        = string
}

variable "oidc_provider_arn" {
  description = "EKS OIDC 제공자 ARN"
  type        = string
}

variable "oidc_provider_url" {
  description = "EKS OIDC 제공자 URL"
  type        = string
}

variable "tags" {
  description = "리소스에 적용할 태그"
  type        = map(string)
  default     = {}
}