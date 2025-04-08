# Terraform 기반 EKS 인프라 구축

이 프로젝트는 Terraform을 통해 AWS EKS 클러스터와 관련 리소스(VPC, 노드 그룹, OIDC, IAM, 애드온, aws-auth 등)를 모듈 방식으로 생성, 관리하는 코드입니다. GitHub에 업로드하여 인프라 코드 형상 관리 및 자동화를 진행할 수 있습니다.

## 1. 프로젝트 개요

- **목적**: AWS 상에서 EKS 클러스터를 비롯한 네트워크, 노드 그룹, IAM, 애드온 등의 리소스를 자동화하여 구축 및 관리합니다.
- **주요 구성요소**:
  - **VPC 모듈**: VPC, 서브넷, NAT Gateway 등 네트워크 리소스 생성
  - **EKS Cluster 모듈**: 클러스터 생성, 보안 그룹 및 로깅 설정
  - **EKS OIDC 모듈**: OIDC 제공자 생성 (Kubernetes OIDC 통합)
  - **EKS IAM 모듈**: EKS 관련 IAM 역할(노드 그룹, 애드온 등) 생성 및 정책 연결
  - **노드 그룹 모듈**: 노드 그룹 생성(시작 템플릿, 오토스케일링, 인스턴스 프로파일 등)
  - **EKS 애드온 모듈**: CoreDNS, kube-proxy, VPC CNI, EBS CSI 등 애드온 관리
  - **EKS 인증(aws-auth) 모듈**: IAM 사용자/역할과 클러스터 연동을 위한 aws-auth ConfigMap 관리

## 2. 디렉터리 구조

```
.
├── environments
│   ├── dev
│   │   └── terraform.tfvars      // 개발 환경 변수 파일
│   └── prod
│       └── terraform.tfvars      // 프로덕션 환경 변수 파일
├── modules
│   ├── eks-auth                  // AWS 인증 설정 (aws-auth ConfigMap, ClusterRoleBinding)
│   ├── eks-cluster               // EKS 클러스터 생성
│   ├── eks-iam                   // EKS 관련 IAM 역할 및 정책
│   ├── eks-oidc                  // OIDC 제공자 생성
│   ├── eks-addons                // CoreDNS, kube-proxy, VPC CNI, EBS CSI 등 애드온 관리
│   ├── node-groups               // EKS 노드 그룹 생성 (시작 템플릿, 자동 스케일링)
│   └── vpc                       // VPC 및 서브넷 생성 (Terraform AWS 모듈 활용)
├── main.tf                       // 전체 모듈 호출 및 의존성 관리
├── versions.tf                   // Terraform 및 Provider 버전 정보
├── output.tf                     // 최종 출력값 설정 (VPC ID, 클러스터 엔드포인트 등)
└── variables.tf                  // 전역 변수 선언
```

> **참고:** 각 모듈 내부에는 `main.tf`, `variables.tf`, `outputs.tf` 등의 파일이 포함되어 있으며, 리소스 생성 및 의존성 관리가 모듈 단위로 분리되어 있습니다.

## 3. 프로젝트 파일 설명

- **`main.tf`**  
  전체 인프라를 구성하는 각 모듈(VPC, EKS Cluster, OIDC, IAM, 노드 그룹, 애드온, aws-auth)을 순차적으로 호출합니다. 명시적 `depends_on` 설정을 통해 리소스 생성 순서를 보장합니다.

- **`versions.tf`**  
  Terraform과 사용 프로바이더(AWS, Kubernetes, TLS, Helm 등)의 최소 버전을 명시합니다.

- **`terraform.tfvars` (dev/prod)**  
  각 환경에 따른 변수값을 관리합니다. 예를 들어, VPC CIDR, 서브넷, 클러스터 이름, 노드 그룹 구성 등이 환경마다 다르게 설정되어 있습니다.

- **각 Module**  
  모듈 단위로 역할이 분리되어 있어, 재사용성과 유지보수가 용이합니다. 환경별 커스터마이징이 필요한 경우 해당 모듈의 변수 파일(variables.tf)을 수정하면 됩니다.

## 4. 파일 실행 방법

### 4.1. 사전 준비 사항
- **Terraform 설치**: [Terraform 공식 다운로드 페이지](https://www.terraform.io/downloads.html)에서 설치합니다.
- **AWS CLI 설치 및 인증**: AWS CLI로 `aws configure`를 통해 AWS 계정 인증을 완료합니다.
- **Git Repository 준비**: GitHub에 저장소를 생성 후, 해당 프로젝트를 클론하거나 새로 추가하여 관리합니다.

### 4.2. 실행 절차

1. **초기화**  
   프로젝트 디렉터리에서 다음 명령어 실행:
   ```bash
   terraform init
   ```
   - 모듈 다운로드 및 백엔드 초기화가 수행됩니다.

2. **플랜 확인**  
   환경별 변수 파일을 지정하여 실행할 계획을 확인합니다.
   - 개발 환경 예시:
     ```bash
     terraform plan -var-file=./environments/dev/terraform.tfvars
     ```
   - 프로덕션 환경 예시:
     ```bash
     terraform plan -var-file=./environments/prod/terraform.tfvars
     ```
   - 출력 결과를 통해 생성될 리소스를 검토합니다.

3. **리소스 적용**  
   계획이 검토된 후 실제 리소스를 생성합니다.
   ```bash
   terraform apply -var-file=./environments/<env>/terraform.tfvars
   ```
   - `<env>` 부분을 dev 또는 prod로 선택합니다.
   - 변경사항 확인 후 `yes` 입력 시 실제 적용됩니다.

4. **리소스 상태 관리**  
   생성 후 `terraform state list` 명령어로 리소스 상태를 확인하고, 필요 시 `terraform refresh` 명령어로 상태 최신화합니다.

5. **변경 사항 적용 및 업데이트**  
   코드 변경 후 다시 `terraform plan`과 `terraform apply`를 통해 업데이트합니다.

## 5. 추가 및 변경 가능한 부분과 변경 방법

프로젝트 내에서 추가하거나 수정할 수 있는 주요 부분과 그 방법은 다음과 같습니다.

### 5.1. 환경별 변수 (tfvars 파일) 수정
- **변경 포인트**:
  - **네트워크 설정**: VPC CIDR, 서브넷, 가용 영역(azs) 변경  
    _예시) dev 환경의 `vpc_cidr`를 "10.1.0.0/16"에서 "10.2.0.0/16"으로 변경_
  - **EKS 클러스터 설정**: 클러스터 이름, 엔드포인트 접근 설정 (프라이빗/퍼블릭 접근 여부, 접근 가능한 CIDR 범위)  
    _예시) `endpoint_public_access_cidrs`를 "0.0.0.0/0" 대신 회사 IP 대역("203.0.113.0/24")으로 변경_
  - **노드 그룹 설정**: 인스턴스 타입, desired/min/max capacity, EBS 볼륨 크기 등  
    _예시) `instance_types` 값을 ["t3.medium"]에서 ["m5.large"]로 변경_

- **변경 방법**:  
  각 환경의 `terraform.tfvars` 파일을 편집 후, 변경 내용을 반영하기 위해 `terraform plan` 및 `terraform apply` 실행

### 5.2. 모듈별 변수 변경 (modules/**/*.tf)
각 모듈 내부의 `variables.tf` 파일에 선언된 변수들을 상황에 맞게 수정할 수 있습니다.
- **vpc 모듈**  
  - NAT Gateway 사용 여부(`single_nat_gateway`)나 DNS 설정 등 추가 옵션을 변경할 수 있습니다.
- **eks-cluster 모듈**  
  - 클러스터 버전(`kubernetes_version`), 보안 그룹 설정, 로깅 옵션, 암호화 설정 등을 수정할 수 있습니다.
- **노드 그룹 모듈**  
  - 시작 템플릿(`aws_launch_template`)의 블록 디바이스, 메타데이터 옵션, 네트워크 인터페이스 설정 등을 커스터마이징할 수 있습니다.
- **eks-addons 모듈**  
  - 애드온 활성화 여부와 버전을 변경할 수 있으며, 필요 시 추가 애드온을 모듈에 추가할 수 있습니다.
- **eks-iam 모듈**  
  - IAM 역할 및 정책(예: lb_controller, cluster_autoscaler, external_dns 등)의 세부 권한과 이름, 정책 JSON을 변경할 수 있습니다.
- **eks-auth 모듈**  
  - aws-auth ConfigMap 내에 추가 사용자나 역할을 정의하는 부분을 수정 가능  
    _예시) 추가 클러스터 관리자 사용자를 입력_

- **변경 방법**:  
  각 모듈의 `variables.tf` 및 관련 리소스 파일을 직접 수정한 후, 필요한 경우 모듈 호출 시 변수 값을 환경 tfvars에서 오버라이드 합니다.

### 5.3. 보안 강화 및 확장
- **클러스터 보안 그룹**:  
  - 인바운드/아웃바운드 규칙을 회사 보안 정책에 맞게 수정  
  - eks-cluster 모듈 내 보안 그룹 설정을 검토하여 제한 조건(CIDR, 포트 등) 변경
- **IAM 정책**:  
  - 최소 권한 원칙에 따라 정책 내용을 수정하고, 필요에 따라 새로운 정책을 추가하여 리소스에 적용
- **OIDC 제공자**:  
  - OIDC 인증서 관련 값이나 thumbprint 값을 갱신하거나, 인증서 검증 정책을 변경할 수 있음

### 5.4. 커스텀 사용자 데이터 스크립트 추가
- **예시**: EC2 인스턴스 부팅 시 실행될 사용자 데이터 스크립트를 추가하여 필요한 초기 설정을 자동 실행  
  ```hcl
  data "template_file" "user_data" {
    template = file("${path.module}/templates/userdata.sh.tpl")
    vars = {
      cluster_name         = var.cluster_name
      cluster_endpoint     = var.cluster_endpoint
      cluster_ca_data      = var.cluster_auth_base64
      bootstrap_extra_args = var.bootstrap_extra_args
      kubelet_extra_args   = var.kubelet_extra_args
    }
  }
  ```
- **변경 방법**:  
  위와 같이 템플릿 파일을 작성한 후, Launch Template의 `user_data` 항목에 `base64encode(data.template_file.user_data.rendered)` 값을 할당하여 적용

### 5.5. State 파일 관리 및 GitHub 업로드 주의사항
- **State 파일 관리**:  
  - 원격 백엔드(S3, DynamoDB)를 사용하여 state 파일을 중앙에서 관리하도록 설정하는 것이 좋습니다.
- **민감 정보 관리**:  
  - AWS 자격 증명 및 민감한 변수값이 포함된 파일은 `.gitignore`에 추가하여 GitHub에 커밋되지 않도록 합니다.

## 6. GitHub 업로드 전 확인 사항

- **민감 정보**: `terraform.tfstate`, `*.tfvars` (특히 프로덕션 값) 및 AWS 자격증명 파일이 업로드되지 않도록 `.gitignore`에 추가합니다.
- **환경 분리**: dev와 prod 환경별로 변수 파일을 분리하여 관리하고, 실수로 프로덕션 환경에 영향을 주지 않도록 주의합니다.
- **코드 리뷰**: 각 모듈 및 변수의 역할과 용도를 명시적으로 주석 달아, 공동 작업 시 누구나 쉽게 수정 및 확장이 가능하도록 합니다.

## 7. 실행 방법 요약

1. **초기화**: `terraform init`
2. **플랜 확인**:  
   - 개발: `terraform plan -var-file=./environments/dev/terraform.tfvars`
   - 프로덕션: `terraform plan -var-file=./environments/prod/terraform.tfvars`
3. **리소스 적용**: `terraform apply -var-file=./environments/<env>/terraform.tfvars`
4. **상태 확인**: `terraform state list` 및 `terraform refresh`

## 8. Dev vs Prod 환경 변수 차이 비교

아래 표는 dev 환경과 prod 환경에서 tfvars 파일의 주요 차이점을 요약합니다.

| 항목                      | dev 환경 설정                                            | prod 환경 설정                                               |
|---------------------------|---------------------------------------------------------|--------------------------------------------------------------|
| **환경(environment)**     | `"dev"`                                                 | `"production"`                                               |
| **VPC CIDR**              | `"10.1.0.0/16"`                                         | `"10.0.0.0/16"`                                              |
| **가용 영역(azs)**         | `["ap-northeast-2a", "ap-northeast-2c"]`                 | `["ap-northeast-2a", "ap-northeast-2b", "ap-northeast-2c"]`    |
| **Private Subnets**       | `["10.1.1.0/24", "10.1.2.0/24"]`                         | `["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]`               |
| **Public Subnets**        | `["10.1.101.0/24", "10.1.102.0/24"]`                     | `["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]`          |
| **EKS 클러스터 이름**     | `"example-app-dev"`                                     | `"example-app-prod"`                                           |
| **노드 그룹 인스턴스 타입**| 기본값: `["t3.medium"]` (SPOT 사용 고려)                 | 고성능 인스턴스: 예, 주석 처리 후 `["m5.2xlarge"]` 선택 가능      |
| **노드 그룹 용량**         | `desired_capacity: 3`, `min_capacity: 2`, `max_capacity: 5` | `desired_capacity: 5`, `min_capacity: 3`, `max_capacity: 10`     |

---

