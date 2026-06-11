## ⚙️ 테라폼 명령어 가이드

개발 환경을 구축하고 관리하기 위한 주요 테라폼 명령어 모음입니다.

```bash
# 테라폼 초기화 및 공급자(Provider) 플러그인 설치
terraform init

# 테라폼 설정 파일의 문법 및 오타 확인
terraform validate

# 인프라 변경 사항 미리보기 (계획 확인)
terraform plan

# 실제 인프라 리소스 구축 및 배포
terraform apply

# 테라폼으로 구축한 모든 인프라 리소스 삭제
terraform destroy

```

## 🛠️ **배포 방법**
팀 프로젝트 진행 시 코드를 동기화하고 배포하는 프로세스입니다. 아래 순서를 준수해 주세요.

```bash
# 작업 시작 전, 원격 저장소의 최신 변경 사항을 먼저 반영합니다.
git pull origin main

# 작업 내용 커밋하기
# 커밋 메시지는 이름(영문): 본인이 작업한 내용 작성 형식으로 통일합니다.
git commit -m "hjin: 인프라 기초 작업 완료"

# 원격 저장소에 푸시 후 공유
git push origin main

# 푸시가 완료되면 반드시 팀 톡방에 알림을 남겨주세요!

# ✨ 브랜치 변경 후 배포해야합니다.
# 1. dev 브랜치를 만들면서 동시에 그 브랜치로 이동합니다.
git checkout -b dev

# 2. 변경된 파일들을 올릴 준비를 합니다. (점 '.'은 모든 변경된 파일을 의미합니다)
git add .

# 3. 버전 기록 메시지(커밋)를 남깁니다.
git commit -m "feat: dev 브랜치 생성 및 파일 추가"

# 4. 원격 저장소(GitHub 등)에 dev 브랜치를 새로 만들며 코드를 올립니다.
git push -u origin dev

# main으로 다시 변경하고 싶은 경우
git checkout main

```
