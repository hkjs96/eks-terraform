variable "cluster_name" {
  description = "EKS 클러스터 이름"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
  default     = ""
}

variable "region" {
  description = "AWS 리전"
  type        = string
  default     = "ap-northeast-2"
}

variable "ebs_csi_role_arn" {
  description = "EBS CSI 역할 ARN"
  type        = string
  default     = ""
}

variable "lb_controller_role_arn" {
  description = "Load Balancer Controller 역할 ARN"
  type        = string
  default     = ""
}

variable "cluster_autoscaler_role_arn" {
  description = "Cluster Autoscaler 역할 ARN"
  type        = string
  default     = ""
}

variable "external_dns_role_arn" {
  description = "External DNS 역할 ARN"
  type        = string
  default     = ""
}

variable "monitoring_role_arn" {
  description = "Prometheus/Grafana용 모니터링 역할 ARN"
  type        = string
  default     = ""
}

variable "logging_role_arn" {
  description = "Fluent Bit용 로깅 역할 ARN"
  type        = string
  default     = ""
}

variable "node_group_depends_on" {
  description = "노드 그룹 의존성을 위한 리소스"
  type        = any
  default     = null
}

variable "tags" {
  description = "리소스에 적용할 태그"
  type        = map(string)
  default     = {}
}

# VPC CNI 애드온
variable "enable_vpc_cni" {
  description = "VPC CNI 애드온 활성화 여부"
  type        = bool
  default     = true
}

variable "vpc_cni_version" {
  description = "VPC CNI 애드온 버전"
  type        = string
  default     = null # null은 최신 버전 사용
}

# CoreDNS 애드온
variable "enable_coredns" {
  description = "CoreDNS 애드온 활성화 여부"
  type        = bool
  default     = true
}

variable "coredns_version" {
  description = "CoreDNS 애드온 버전"
  type        = string
  default     = null
}

# kube-proxy 애드온
variable "enable_kube_proxy" {
  description = "kube-proxy 애드온 활성화 여부"
  type        = bool
  default     = true
}

variable "kube_proxy_version" {
  description = "kube-proxy 애드온 버전"
  type        = string
  default     = null
}

# EBS CSI 드라이버
variable "enable_ebs_csi" {
  description = "EBS CSI 드라이버 애드온 활성화 여부"
  type        = bool
  default     = true
}

variable "ebs_csi_version" {
  description = "EBS CSI 드라이버 애드온 버전"
  type        = string
  default     = null
}

# AWS Load Balancer Controller
variable "enable_lb_controller" {
  description = "AWS Load Balancer Controller 활성화 여부"
  type        = bool
  default     = true
}

variable "lb_controller_version" {
  description = "AWS Load Balancer Controller 버전"
  type        = string
  default     = "1.6.2"
}

# Cluster Autoscaler
variable "enable_cluster_autoscaler" {
  description = "Cluster Autoscaler 활성화 여부"
  type        = bool
  default     = true
}

variable "cluster_autoscaler_version" {
  description = "Cluster Autoscaler 버전"
  type        = string
  default     = "9.29.3"
}

# Metrics Server
variable "enable_metrics_server" {
  description = "Metrics Server 활성화 여부"
  type        = bool
  default     = true
}

variable "metrics_server_version" {
  description = "Metrics Server 버전"
  type        = string
  default     = "3.11.0"
}

# External DNS
variable "enable_external_dns" {
  description = "External DNS 활성화 여부"
  type        = bool
  default     = false
}

variable "external_dns_version" {
  description = "External DNS 버전"
  type        = string
  default     = "6.28.5"
}

# Prometheus Stack (신규 추가)
variable "enable_prometheus_stack" {
  description = "Prometheus Stack 활성화 여부"
  type        = bool
  default     = false
}

variable "prometheus_stack_version" {
  description = "Prometheus Stack 버전"
  type        = string
  default     = "55.5.0"
}

variable "grafana_admin_password" {
  description = "Grafana 관리자 비밀번호"
  type        = string
  default     = "prom-operator"
  sensitive   = true
}

# Fluent Bit (신규 추가)
variable "enable_fluent_bit" {
  description = "Fluent Bit 활성화 여부"
  type        = bool
  default     = false
}

variable "fluent_bit_version" {
  description = "Fluent Bit 버전"
  type        = string
  default     = "0.39.0"
}