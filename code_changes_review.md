# 🔍 인프라 개선 아키텍처 비교 분석 보고서
> **대상:** 원본 브랜치(`origin/main`) $\rightarrow$ 개선본(`origin/dev`)

이 보고서는 원본 브랜치에서 개선본 브랜치로 코드가 변경되면서 발생한 아키텍처 변화를 **[삭제된 것]**, **[옮겨진 것]**, **[생성 및 변경된 것]**으로 명확히 분류하고, 각 변경 사항에 대한 기술적 배경 및 상세 이유를 기록한 문서입니다.

---

## 1. 🗑️ [삭제된 것] (Deleted / Removed)

원활한 로컬 개발망 배포 및 인프라 구축의 의존성 오류를 차단하기 위해 불필요하거나 복잡도를 유발하는 리소스와 설정을 과감히 삭제했습니다.

### ① 테라폼 레벨의 ALB 리스너 규칙 리소스 삭제
* **대상 파일:** [alb.tf](./modules/infra/eks-cluster/alb.tf) (`aws_lb_listener_rule` 리소스들)
* **변경 이유:** EKS 내부의 AWS Load Balancer Controller가 Kubernetes의 `TargetGroupBinding` Custom Resource를 통해 파드 IP를 타겟 그룹에 동적으로 직접 바인딩합니다. 따라서 테라폼 단에서 정적으로 리스너 규칙을 선언할 필요가 없어져 중복 관리를 제거했습니다.
* **추가 설명:** 테라폼에서 룰 리소스를 지워도, 쿠버네티스 Ingress 및 TargetGroupBinding 매니페스트가 배포될 때 AWS ALB Controller가 AWS 상에 리스너 룰을 알아서 자동으로 동적 갱신해 주므로 라우팅이 깨지지 않습니다.

### ② 보안 그룹의 무분별한 `create_before_destroy` 설정 삭제
* **대상 파일:** [security_group.tf](./modules/networking/security_group.tf) (`alb`, `eks`, `aurora`, `redis`, `dms` 보안 그룹)
* **변경 이유:** 여러 리소스가 서로의 보안 그룹 ID를 양방향으로 참조(Circular Reference)하고 있는 상황에서 테라폼이 변경 사항을 배포하려 할 때, 기존 보안 그룹이 의존성 때문에 삭제되지 못하고 배포 프로세스가 중단되는 에러가 고질적으로 발생합니다. 배포 안정성을 위해 Bastion을 제외한 다른 보안 그룹의 강제 선제 생성 규칙을 삭제했습니다.
* **추가 설명:** `create_before_destroy`를 적용하면 무중단 교체에는 유리하지만, EKS 노드 그룹 보안 그룹과 DB 보안 그룹이 상호 참조 관계여서 테라폼 상에서 배포 교착 상태(Deadlock) 에러를 뿜으며 멈춥니다. 프로덕션망에서 무중단을 보장해야 한다면, 보안 그룹 규칙(`aws_security_group_rule`)을 별개 리소스로 분리 선언하여 이 교착 상태를 완벽히 우회할 수 있습니다.

### ③ Kubernetes 오토스케일링 매니페스트 파일 삭제
* **대상 파일:** 원래 `modules/infra/k8s-manifests/` 경로에 있던 `worker-hpa.yaml` 및 `worker-scaledobject.yaml` 파일 전체 (현재 삭제됨)
* **변경 이유:** SQS 대기열 길이에 반응하여 Worker Pod 개수를 동적으로 조절하는 KEDA ScaledObject 및 HPA를 작동시키기 위해서는, EKS 내부에 별도의 Helm 차트 및 권한 연동(IRSA) 등 사전 설치물이 많이 요구됩니다. 로컬 테스트 및 초기 개발 단계의 구동 난이도를 대폭 낮추고 단순화하기 위해 해당 모스케일링 설정을 제거했습니다.

### ④ Kubernetes 외부 시크릿 연동 매니페스트 파일 삭제
* **대상 파일:** 원래 `modules/infra/k8s-manifests/` 경로에 있던 `secret-store.yaml` 파일 전체 (현재 삭제됨)
* **변경 이유:** External Secrets Operator(ESO)는 AWS Secrets Manager와 K8s Secret을 연동해 주는 유용한 도구이지만, 이 역시 사전 헬름 차트 설치와 복잡한 IAM 인증 절차가 수반됩니다. 경량화된 로컬 검증 및 개발망 테스트가 가능하도록 이를 제거하고 수동 Secret 및 ConfigMap 주입 방식으로 변경했습니다.

### ⑤ Ingress 내 HTTPS/SSL 강제 리다이렉트 및 인증서 바인딩 삭제
* **대상 파일:** [ingress.yaml](./modules/infra/k8s-manifests/ingress.yaml) (어노테이션 `ssl-redirect`, `certificate-arn`, `security-groups` 및 HTTPS 443 포트 리스닝)
* **변경 이유:** 개발(Dev) 환경에서는 인증서가 없는 HTTP(80) 통신만으로도 충분히 백엔드/프론트엔드 연동 및 기능 검증이 가능합니다. 불필요한 SSL 인증서 발급 대기 시간 및 ALB 바인딩 에러를 유방하는 어노테이션들을 제거하여 구조를 단순화했습니다.

### ⑥ 테라폼 개발 환경 더미 변수 설정값 삭제
* **대상 파일:** [terraform.tfvars](./environments/dev/terraform.tfvars) (`cloudfront_domain_name`, `cloudfront_zone_id`, `alb_dns_name`, `alb_zone_id` 값)
* **변경 이유:** 개선안에서는 모듈 아웃풋의 동적 바인딩 및 최상위 DNS 이관을 적용함에 따라, 배포 전 임시로 하드코딩해 주던 무의미한 더미 도메인 변수값들이 필요 없어졌기 때문에 정리했습니다.

---

## 2. 🚚 [옮겨진 것] (Moved / Migrated)

모듈 간의 의존성 구조를 정상화하고 순환 참조 에러를 해결하기 위해 리소스의 선언 위치를 이관했습니다.

### ① Route53 DNS 레코드 리소스 이관
* **이동 전 위치:** `modules/networking/route53.tf` (원본 위치)
* **이동 후 위치:** [route53.tf](./environments/prod/route53.tf) [NEW]
* **이유:** `networking` 모듈 내부에서 CloudFront Domain 및 ALB DNS의 A레코드와 DB의 CNAME 레코드를 생성하려고 하면, EKS 클러스터나 데이터베이스가 다 뜬 다음에 나오는 Endpoint를 네트워킹 모듈로 거꾸로 주입해 주어야 하는 **순환 의존성(Dependency Cycle) 오류**가 발생하여 테라폼 배포가 차단됩니다. 이를 완전히 해결하고자 모듈을 호출하는 최상위 루트 레벨에서 최종 아웃풋들을 한 번에 엮어주는 설계로 이관했습니다.

---

## 3. ✨ [생성 및 변경된 것] (Created / Modified)

안정적인 자원 공급, 의존성 오류 예방, 개발 생산성 향상을 목적으로 인프라 스펙을 조정하고 자동화 태그 및 가이드를 추가했습니다.

### ① EKS 워커 노드 인스턴스 사양 업그레이드
* **대상 파일:** [main.tf](./modules/infra/eks-cluster/main.tf) (`fixed_node_group` 의 `instance_types`)
* **변경 내용:** `t3.medium` (RAM 4GiB) $\rightarrow$ `t3.large` (RAM 8GiB)
* **변경 이유:** 백엔드, 워커, Redis 등 다수의 파드가 단일 워커 노드에서 구동될 때, 메모리 부족으로 인해 파드가 켜지지 않거나 OOM(Out of Memory)으로 비정상 종료되는 현상을 방지하고 안정적인 컴퓨팅 자원을 보장하기 위해 상향했습니다.

### ② ALB 리스너의 동적 제어 로직 구현
* **대상 파일:** [alb.tf](./modules/infra/eks-cluster/alb.tf)
* **변경 내용:** dev/prod 환경 분기 $\rightarrow$ ACM 인증서 ARN 존재 여부(`acm_alb_certificate_arn != ""`) 분기
* **변경 이유:** 환경 정보와 상관없이 SSL 인증서의 유무에 맞춰 HTTPS 443 리다이렉트 규칙 또는 HTTP 80 포워딩 규칙을 테라폼이 스스로 판단하여 동적으로 설정하도록 제어 로직을 유연하게 개선했습니다.

### ③ Bastion OS 패키지 최신화 및 의존성 오류 방지
* **대상 파일:** [bastion.tf](./modules/networking/bastion.tf), [security_group.tf](./modules/networking/security_group.tf)
* **변경 내용:** `mysql8.0` 패키지 설치 $\rightarrow$ `maria105` 패키지 설치 및 Bastion SG에 `name_prefix` 적용
* **변경 이유:** 최신 Amazon Linux 2023 OS 환경에서 dnf 레포지토리 의존성 문제를 방지하기 위해 `mariadb` 클라이언트로 교체했습니다. 또한 Bastion 보안 그룹에만 `lifecycle { create_before_destroy = true }` 정책 및 `name_prefix`를 적용하여 보안 그룹 변경 배포 시 기존 그룹이 인스턴스에 묶여 삭제되지 않고 테라폼이 멈추는 고질적인 의존성 예방을 구현했습니다.

### ④ EKS Ingress Controller 자동 인식을 위한 서브넷 태그 추가
* **대상 파일:** [main.tf](./modules/networking/main.tf) (서브넷 리소스 선언부)
* **변경 내용:** 퍼블릭 서브넷에 `"kubernetes.io/role/elb" = "1"`, 프라이빗 서브넷에 `"kubernetes.io/role/internal-elb" = "1"` 태그 추가
* **변경 이유:** Kubernetes 내부의 AWS Load Balancer Controller가 Ingress 배포 시 실제 AWS ALB(로드밸런서)를 어느 서브넷에 생성 및 연결해야 하는지 자동으로 탐색하고 매핑할 수 있도록 필수 표준 태그를 주입했습니다.

### ⑤ DMS 마이그레이션 복제 인스턴스 사양 상향
* **대상 파일:** [variables.tf](./modules/database/variables.tf) (`dms_instance_class` 기본값)
* **변경 내용:** `dms.t3.micro` $\rightarrow$ `dms.t3.small`
* **변경 이유:** DB 마이그레이션 작업 시 발생할 수 있는 네트워크 대역폭 제한 및 처리량 병목을 개선하여 안정적이고 빠른 복제를 도모했습니다.

### ⑥ 상세 개발자 런북 및 로컬 연동 가이드 추가
* **대상 파일:** [README.md](./README.md)
* **변경 내용:** 1~8단계 아키텍처 워크플로우 맵 수록, EKS 2단계 순차 배포 노하우 가이드, RDS SSM 터널링 명령어, 로컬 Redis 실행 명령어, curl API 테스트 예제 수록, DB/Redis 로컬 기동 및 연동 아키텍처 안내 수록
* **변경 이유:** 개발자가 인프라를 처음부터 끝까지 꼬임 없이 배포하고, 로컬 환경에서 AWS 인프라(DB, SQS 등)와 무리 없이 연동 테스트를 진행할 수 있도록 개발 가이드를 대폭 강화했습니다.

### ⑦ 프로젝트명 중복 충돌 방지를 위한 식별자 변경
* **대상 파일:** [terraform.tfvars](./environments/dev/terraform.tfvars)
* **변경 내용:** 프로젝트 식별자 `project_name`을 `"team-train-20260611"`로 설정
* **변경 이유:** 여러 작업자가 동일한 공용 AWS 계정에서 동시에 테스트 배포를 시도할 때 전역 리소스(S3 버킷 등) 중복 충돌 에러가 발생하는 것을 방지하기 위해 날짜 접미사를 추가하여 고유하게 세팅했습니다.

---
## 4. 🛡️ [상용 아키텍처 규격 복구를 완료한 핵심 기능]

기존 설계에 포함되었으나 로컬 테스트 및 초기 구동 편의상 제외했었던 핵심 리소스(KEDA, ESO, HTTPS Ingress, WAF, 장애 모니터링 알림)들을 개선본 브랜치(`origin/dev`)에 모두 통합 및 복구 완료했습니다. 각 리소스의 기능적 의의와 상용망 운영 시의 역할은 다음과 같습니다.

### ① 데이터베이스 비밀번호의 중앙 보안 통제 및 자동 로테이션
* **관련 파일:** [secret-store.yaml](./modules/infra/k8s-manifests/secret-store.yaml) (복구 완료)
* **적용된 설계:** ESO(External Secrets Operator)를 활성화하여 AWS Secrets Manager의 `team-train-db-secret` 암호를 K8s 내부에 `train-secret`으로 안전하고 자동화된 방식으로 매핑합니다.
* **역할 & 기대 효과:** 주기적인 패스워드 변경(Rotation)이 수행되어도 수동 재배포 없이 쿠버네티스 파드가 자동으로 갱신된 암호를 동기화하여 운영 안정성을 확보합니다.

### ② SQS 대기열(이벤트) 기반의 파드 오토스케일링 및 비용 최적화
* **관련 파일:** [worker-scaledobject.yaml](./modules/infra/k8s-manifests/worker-scaledobject.yaml), [worker-hpa.yaml](./modules/infra/k8s-manifests/worker-hpa.yaml) (복구 완료)
* **적용된 설계:** KEDA ScaledObject 및 HorizontalPodAutoscaler를 추가하여 SQS 큐에 적체된 예약 요청 메시지가 늘어날 때 백그라운드 워커 파드가 자동으로 확장(2개 $\rightarrow$ 최대 10개)되도록 구성했습니다.
* **역할 & 기대 효과:** 트래픽 폭주 시 대기 시간을 감축하여 대량 예매 요청을 병목 없이 소화하고, 야간 등 대기열이 빌 때는 파드를 최소화하여 불필요한 컴퓨팅 과금을 차단합니다.

### ③ 외부 구간 암호화 및 브라우저 혼합 콘텐츠 오류 방지 (HTTPS 활성화)
* **관련 파일:** [ingress.yaml](./modules/infra/k8s-manifests/ingress.yaml) (복구 완료)
* **적용된 설계:** Ingress의 HTTPS 443 리스너 포트를 추가하고, SSL 리다이렉트 어노테이션 및 ACM 인증서 바인딩 설정을 활성화했습니다.
* **역할 & 기대 효과:** 전송 구간 암호화를 통해 주요 기밀 데이터를 보호하고, 프론트엔드가 HTTPS로 서빙될 때 발생하기 쉬운 브라우저 혼합 콘텐츠(Mixed Content) 통신 차단 문제를 미연에 방지합니다.

### ④ 웹 방화벽(WAF) 및 세밀한 ALB 인바운드 보안 통제
* **관련 파일:** [ingress.yaml](./modules/infra/k8s-manifests/ingress.yaml) (어노테이션 설정), [cloudfront.tf](./modules/networking/cloudfront.tf) (WAF 연동)
* **적용된 설계:** Ingress에 ALB 전용 보안 그룹 바인딩 어노테이션을 복구하고, CloudFront 단에서의 WAF 보호 정책을 활성화했습니다.
* **역할 & 기대 효과:** SQL 인젝션, XSS, CSRF 등 악성 웹 해킹 공격 트래픽을 아키텍처 전면에서 무력화하여 웹 애플리케이션 보안 등급을 상용 수준으로 격상시킵니다.

### ⑤ 실시간 인프라 장애 모니터링 및 경보 파이프라인 가동
* **관련 파일:** [main.tf](./environments/dev/main.tf) (알림 모듈 복구), [variables.tf](./environments/dev/variables.tf), [terraform.tfvars](./environments/dev/terraform.tfvars) (설정 복구 완료)
* **적용된 설계:** 테라폼 코드에서 `module "notification"` 호출부 주석을 제거하고, SES/SNS 알림에 필요한 이메일 변수 값을 복원했습니다.
* **역할 & 기대 효과:** 백엔드 오류, DB/Redis 불능, SQS 대기열 지연 발생 시 운영자에게 즉시 실시간 이메일/알림이 발송되어 선제적인 장애 탐지 및 대응을 가능하게 만듭니다.
