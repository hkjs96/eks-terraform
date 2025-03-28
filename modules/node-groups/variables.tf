variable "cluster_name" {
  description = "EKS 클러스터 이름"
  type        = string
}

variable "cluster_endpoint" {
  description = "EKS 클러스터 엔드포인트"
  type        = string
}

variable "node_group_name" {
  description = "노드 그룹 이름"
  type        = string
}

variable "subnet_ids" {
  description = "노드 그룹이 배포될 서브넷 ID 목록"
  type        = list(string)
}

variable "disk_size" {
  description = "노드 디스크 크기(GB)"
  type        = number
  default     = 20
}

variable "desired_capacity" {
  description = "노드 그룹 기본 크기"
  type        = number
  default     = 2
}

variable "min_capacity" {
  description = "노드 그룹 최소 크기"
  type        = number
  default     = 1
}

variable "max_capacity" {
  description = "노드 그룹 최대 크기"
  type        = number
  default     = 3
}

variable "max_unavailable" {
  description = "업데이트 중 최대 사용 불가능 노드 수"
  type        = number
  default     = 1
}

variable "key_name" {
  description = "EC2 키 페어 이름 (선택사항)"
  type        = string
  default     = null
}

variable "bootstrap_extra_args" {
  description = "부트스트랩 스크립트에 전달할 추가 인수"
  type        = string
  default     = ""
}

variable "kubelet_extra_args" {
  description = "kubelet에 전달할 추가 인수"
  type        = string
  default     = ""
}

variable "node_labels" {
  description = "노드에 적용할 쿠버네티스 레이블"
  type        = map(string)
  default     = {}
}

variable "node_taint_key" {
  description = "노드 테인트 키"
  type        = string
  default     = ""
}

variable "node_taint_value" {
  description = "노드 테인트 값"
  type        = string
  default     = ""
}

variable "node_taint_effect" {
  description = "노드 테인트 효과"
  type        = string
  default     = ""
}

variable "tags" {
  description = "리소스에 적용할 태그"
  type        = map(string)
  default     = {}
}
