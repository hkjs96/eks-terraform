# EKS 노드 그룹 모듈 (modules/node-groups/main.tf)

# 1. EKS 노드 그룹 IAM 역할 생성
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

# 2. EKS 노드 그룹 IAM 정책 연결
resource "aws_iam_role_policy_attachment" "node_AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.node_group.name
}

resource "aws_iam_role_policy_attachment" "node_AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.node_group.name
}

resource "aws_iam_role_policy_attachment" "node_AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.node_group.name
}

# 3. 노드 그룹 시작 템플릿 생성
resource "aws_launch_template" "node_group" {
  name = "${var.cluster_name}-node-group-template"
  
  block_device_mappings {
    device_name = "/dev/xvda"
    
    ebs {
      volume_size           = var.disk_size
      volume_type           = "gp3"
      encrypted             = true
      delete_on_termination = true
    }
  }
  
  # 노드 시작 시 실행될 사용자 데이터 스크립트
  user_data = base64encode(templatefile("${path.module}/templates/userdata.sh.tpl", {
    cluster_name         = var.cluster_name
    cluster_endpoint     = var.cluster_endpoint
    bootstrap_extra_args = var.bootstrap_extra_args
    kubelet_extra_args   = var.kubelet_extra_args
  }))
  
  tag_specifications {
    resource_type = "instance"
    tags = merge(
      var.tags,
      {
        "Name" = "${var.cluster_name}-node"
      }
    )
  }
  
  # IMDSv2 필수화 설정
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }
  
  # 모니터링 활성화
  monitoring {
    enabled = true
  }
  
  # 노드에 SSH 접속을 위한 키 페어 (선택사항)
  key_name = var.key_name
  
  # 인스턴스 프로파일 설정을 위한 IAM 역할 연결
  #  iam_instance_profile {
    #    name = aws_iam_instance_profile.node_group.name
    #  }
  
  tags = var.tags
}

# 4. 노드 인스턴스 프로파일 생성
#resource "aws_iam_instance_profile" "node_group" {
#  name = "${var.cluster_name}-node-instance-profile"
#  role = aws_iam_role.node_group.name
#}

# 5. EKS 관리형 노드 그룹 생성
resource "aws_eks_node_group" "this" {
  cluster_name    = var.cluster_name
  node_group_name = var.node_group_name
  node_role_arn   = aws_iam_role.node_group.arn
  subnet_ids      = var.subnet_ids
  
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
  
  # 태그
  tags = merge(
    var.tags,
    {
      "Name" = var.node_group_name
    }
  )
  
  # 의존성 설정
  depends_on = [
    aws_iam_role_policy_attachment.node_AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.node_AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.node_AmazonEC2ContainerRegistryReadOnly,
  ]
  
  # 노드 그룹에 적용할 레이블
  labels = var.node_labels
  
  # 수명 주기 관리
  lifecycle {
    create_before_destroy = true
    ignore_changes = [
      scaling_config[0].desired_size
    ]
  }
}
