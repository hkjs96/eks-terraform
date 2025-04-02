# 서브넷 데이터 소스 참조 추가
data "aws_subnet" "private" {
  count = length(var.subnet_ids)
  id    = var.subnet_ids[count.index]
}

# EKS 클러스터 데이터 소스 참조 추가
data "aws_eks_cluster" "this" {
  name = var.cluster_name
}

# 노드 그룹 IAM 역할 생성
resource "aws_iam_role" "node_group" {
  name = "${var.cluster_name}-node-group-role"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })

  tags = var.tags
}

# IAM 정책 연결
resource "aws_iam_role_policy_attachment" "node_AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.node_group.name
  
  depends_on = [aws_iam_role.node_group]
}

resource "aws_iam_role_policy_attachment" "node_AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.node_group.name
  
  depends_on = [aws_iam_role.node_group]
}

resource "aws_iam_role_policy_attachment" "node_AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.node_group.name
  
  depends_on = [aws_iam_role.node_group]
}

# SSM 관리를 위한 정책 연결
resource "aws_iam_role_policy_attachment" "node_AmazonSSMManagedInstanceCore" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.node_group.name
  
  depends_on = [aws_iam_role.node_group]
}

# 노드 인스턴스 프로파일 생성
resource "aws_iam_instance_profile" "node_group" {
  name = "${var.cluster_name}-node-instance-profile"
  role = aws_iam_role.node_group.name
  
  depends_on = [aws_iam_role.node_group]
}

# Node 보안 그룹 생성 (추가)
resource "aws_security_group" "node" {
  name        = "${var.cluster_name}-node-sg"
  description = "Security group for EKS worker nodes"
  vpc_id      = data.aws_subnet.private[0].vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.tags,
    {
      "Name" = "${var.cluster_name}-node-sg",
      "kubernetes.io/cluster/${var.cluster_name}" = "owned"
    }
  )
}

# 클러스터와 노드 간 통신 허용 (추가)
resource "aws_security_group_rule" "node_to_cluster" {
  description              = "Allow node to communicate with the cluster API Server"
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = var.cluster_security_group_id
  source_security_group_id = aws_security_group.node.id
  to_port                  = 443
  type                     = "ingress"
}

resource "aws_security_group_rule" "cluster_to_node" {
  description              = "Allow cluster to communicate with nodes"
  from_port                = 1025
  protocol                 = "tcp"
  security_group_id        = aws_security_group.node.id
  source_security_group_id = var.cluster_security_group_id

  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "node_to_node" {
  description              = "Allow nodes to communicate with each other"
  from_port                = 0
  protocol                 = "-1"
  security_group_id        = aws_security_group.node.id
  source_security_group_id = aws_security_group.node.id
  to_port                  = 65535
  type                     = "ingress"
}

# user_data 템플릿 렌더링 - 변수 추가
# data "template_file" "user_data" {
#   template = file("${path.module}/templates/userdata.sh.tpl")
#   vars = {
#     cluster_name         = var.cluster_name
#     cluster_endpoint     = var.cluster_endpoint
#     cluster_ca_data      = var.cluster_auth_base64  # CA 인증서 데이터 추가
#     bootstrap_extra_args = var.bootstrap_extra_args
#     kubelet_extra_args   = var.kubelet_extra_args
#   }
# }

# 노드 그룹 시작 템플릿 생성
resource "aws_launch_template" "node_group" {
  name_prefix = "${var.cluster_name}-node-group-"
  description = "Launch template for EKS ${var.cluster_name} node group"
  
  # 사용자 데이터 스크립트 - 템플릿 파일에서 렌더링
  # user_data = base64encode(data.template_file.user_data.rendered)
  
  # EBS 루트 볼륨 구성
  block_device_mappings {
    device_name = "/dev/xvda"
    
    ebs {
      volume_size           = var.disk_size
      volume_type           = "gp3"
      encrypted             = true
      delete_on_termination = true
      iops                  = 3000  # gp3의 경우 기본값
      throughput            = 125   # gp3의 경우 기본값
    }
  }
  
  # IMDSv2 필수화 설정 (보안 강화)
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
    instance_metadata_tags      = "enabled"
  }
  
  # 모니터링 활성화
  monitoring {
    enabled = true
  }
  
  # 네트워크 인터페이스 설정 (추가)
  network_interfaces {
    associate_public_ip_address = true  # 퍼블릭 IP 할당 활성화
    security_groups             = [aws_security_group.node.id]
    delete_on_termination       = true
  }
  
  # 인스턴스 태그 설정
  tag_specifications {
    resource_type = "instance"
    tags = merge(
      var.tags,
      {
        "Name" = "${var.cluster_name}-node"
      }
    )
  }
  
  # 볼륨 태그 설정
  tag_specifications {
    resource_type = "volume"
    tags = merge(
      var.tags,
      {
        "Name" = "${var.cluster_name}-node-volume"
      }
    )
  }
  
  # SSH 접속을 위한 키 페어 (선택사항)
  key_name = var.key_name
  
  tags = var.tags
  
  lifecycle {
    create_before_destroy = true
  }
  
  depends_on = [aws_iam_instance_profile.node_group]
}

# EKS 관리형 노드 그룹 생성 (나머지 코드 동일)
resource "aws_eks_node_group" "this" {
  cluster_name    = var.cluster_name  
  node_group_name = var.node_group_name
  node_role_arn   = aws_iam_role.node_group.arn
  subnet_ids      = var.subnet_ids    
  capacity_type   = var.capacity_type
  
  # 시작 템플릿 사용
  launch_template {
    id      = aws_launch_template.node_group.id
    version = aws_launch_template.node_group.latest_version
  }
  
  # 오토스케일링 설정
  scaling_config {
    desired_size = var.desired_capacity
    max_size     = var.max_capacity
    min_size     = var.min_capacity
  }
  
  # 업데이트 설정
  update_config {
    max_unavailable = var.max_unavailable
  }
  
  # 노드 그룹에 적용할 레이블
  labels = var.node_labels
  
  # 노드 그룹에 적용할 테인트 (조건부)
  dynamic "taint" {
    for_each = var.node_taints
    content {
      key    = taint.value.key
      value  = taint.value.value
      effect = taint.value.effect
    }
  }
  
  # 태그
  tags = merge(
    var.tags,
    {
      "Name" = var.node_group_name
    }
  )
  
  # 의존성 설정 - 명시적 의존성 추가
  depends_on = [
    aws_iam_role_policy_attachment.node_AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.node_AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.node_AmazonEC2ContainerRegistryReadOnly,
    aws_launch_template.node_group,
    data.aws_eks_cluster.this,
    aws_security_group.node,
    aws_security_group_rule.node_to_cluster,
    aws_security_group_rule.cluster_to_node,
    aws_security_group_rule.node_to_node
  ]
  
  # 수명 주기 관리
  lifecycle {
    create_before_destroy = true
    ignore_changes = [
      scaling_config[0].desired_size
    ]
  }
}