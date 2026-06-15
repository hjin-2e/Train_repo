# ==============================================================================
# Frontend CI/CD Pipeline
# ==============================================================================
# 구성 요소:
#   [GitHub OIDC]  GitHub Actions가 키 없이 AWS에 인증하기 위한 설정
#   [S3]           CodePipeline 아티팩트 저장 버킷 (버전 관리 필수)
#   [IAM]          CodeBuild Role, CodePipeline Role, GitHub Actions Role
#   [CodeBuild]    S3 sync + CloudFront 캐시 무효화 실행
#   [CodePipeline] Source(S3) → Deploy(CodeBuild) 2단계 파이프라인
# ==============================================================================

# 현재 AWS 계정 및 리전 정보
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# ==============================================================================
# 1. S3 아티팩트 버킷
#    GitHub Actions가 빌드 결과물(deployment.zip)을 업로드하는 버킷
#    CodePipeline Source Stage가 이 버킷을 감시합니다.
# ==============================================================================
resource "aws_s3_bucket" "pipeline_artifact" {
  bucket        = "${var.project_name}-pipeline-artifacts"
  force_destroy = true

  tags = {
    Name        = "${var.project_name}-pipeline-artifacts"
    Environment = var.environment
    Purpose     = "CI/CD artifact store for CodePipeline"
  }
}

resource "aws_s3_bucket_public_access_block" "pipeline_artifact" {
  bucket = aws_s3_bucket.pipeline_artifact.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# [필수] CodePipeline S3 Source는 버전 관리가 활성화된 버킷만 감시 가능합니다.
resource "aws_s3_bucket_versioning" "pipeline_artifact" {
  bucket = aws_s3_bucket.pipeline_artifact.id

  versioning_configuration {
    status = "Enabled"
  }
}

# ==============================================================================
# 2. GitHub Actions OIDC 설정
#    GitHub Actions가 IAM Access Key 없이 AWS 리소스에 안전하게 접근합니다.
# ==============================================================================

# GitHub OIDC Identity Provider (계정당 1개만 존재 가능)
resource "aws_iam_openid_connect_provider" "github" {
  count = var.create_github_oidc_provider ? 1 : 0

  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  # GitHub OIDC의 공식 인증서 지문 (2개 모두 등록 권장)
  thumbprint_list = [
    "6938fd4d98bab03faadb97b34396831e3780aea1",
    "1c58a3a8518e8759bf075b76b750d4f2df264fcd"
  ]

  tags = {
    Name        = "github-actions-oidc-provider"
    Environment = var.environment
  }
}

# GitHub Actions가 수임할 IAM Role
resource "aws_iam_role" "github_actions" {
  name = "${var.project_name}-${var.environment}-github-actions-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          # create_github_oidc_provider = true: 위에서 생성한 Provider ARN 사용
          # create_github_oidc_provider = false: 기존 Provider ARN을 조합하여 사용
          Federated = var.create_github_oidc_provider ? aws_iam_openid_connect_provider.github[0].arn : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/token.actions.githubusercontent.com"
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            # "sts.amazonaws.com"으로 audience가 설정된 토큰만 허용
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
          StringLike = {
            # 지정된 GitHub 레포(var.github_repo)의 모든 브랜치/이벤트에서만 수임 허용
            "token.actions.githubusercontent.com:sub" = "repo:${var.github_repo}:*"
          }
        }
      }
    ]
  })

  tags = {
    Name        = "${var.project_name}-github-actions-role"
    Environment = var.environment
  }
}

# GitHub Actions Role에 부여할 정책: S3 아티팩트 버킷 업로드 권한만 최소 부여
resource "aws_iam_role_policy" "github_actions" {
  name = "${var.project_name}-${var.environment}-github-actions-policy"
  role = aws_iam_role.github_actions.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowArtifactUpload"
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.pipeline_artifact.arn,
          "${aws_s3_bucket.pipeline_artifact.arn}/*"
        ]
      }
    ]
  })
}

# ==============================================================================
# 3. CodeBuild IAM Role
#    CodeBuild가 프론트엔드 S3 동기화 및 CloudFront 무효화를 수행합니다.
# ==============================================================================
resource "aws_iam_role" "codebuild" {
  name = "${var.project_name}-${var.environment}-codebuild-frontend-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "codebuild.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name        = "${var.project_name}-codebuild-frontend-role"
    Environment = var.environment
  }
}

resource "aws_iam_role_policy" "codebuild" {
  name = "${var.project_name}-${var.environment}-codebuild-frontend-policy"
  role = aws_iam_role.codebuild.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      # CodeBuild 빌드 로그를 CloudWatch Logs에 기록
      {
        Sid    = "AllowCloudWatchLogs"
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/codebuild/*"
      },
      # CodePipeline 아티팩트 버킷에서 소스 읽기
      {
        Sid    = "AllowArtifactRead"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion"
        ]
        Resource = "${aws_s3_bucket.pipeline_artifact.arn}/*"
      },
      # 프론트엔드 S3 버킷에 배포 파일 동기화 (aws s3 sync)
      {
        Sid    = "AllowFrontendS3Sync"
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket",
          "s3:GetObject"
        ]
        Resource = [
          "arn:aws:s3:::${var.frontend_bucket_name}",
          "arn:aws:s3:::${var.frontend_bucket_name}/*"
        ]
      },
      # CloudFront 캐시 무효화 (aws cloudfront create-invalidation)
      {
        Sid    = "AllowCloudFrontInvalidation"
        Effect = "Allow"
        Action = ["cloudfront:CreateInvalidation"]
        Resource = "arn:aws:cloudfront::${data.aws_caller_identity.current.account_id}:distribution/${var.cloudfront_distribution_id}"
      }
    ]
  })
}

# ==============================================================================
# 4. CodePipeline IAM Role
#    CodePipeline이 S3에서 소스를 읽고 CodeBuild를 실행합니다.
# ==============================================================================
resource "aws_iam_role" "codepipeline" {
  name = "${var.project_name}-${var.environment}-codepipeline-frontend-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "codepipeline.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name        = "${var.project_name}-codepipeline-frontend-role"
    Environment = var.environment
  }
}

resource "aws_iam_role_policy" "codepipeline" {
  name = "${var.project_name}-${var.environment}-codepipeline-frontend-policy"
  role = aws_iam_role.codepipeline.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      # S3 아티팩트 버킷: 소스 읽기 + 파이프라인 내부 아티팩트 읽기/쓰기
      {
        Sid    = "AllowS3ArtifactAccess"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:GetBucketVersioning",
          "s3:PutObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.pipeline_artifact.arn,
          "${aws_s3_bucket.pipeline_artifact.arn}/*"
        ]
      },
      # CodeBuild 프로젝트 실행 및 상태 조회
      {
        Sid    = "AllowCodeBuildExecution"
        Effect = "Allow"
        Action = [
          "codebuild:BatchGetBuilds",
          "codebuild:StartBuild"
        ]
        Resource = aws_codebuild_project.frontend_deploy.arn
      }
    ]
  })
}

# ==============================================================================
# 5. CodeBuild Project: 프론트엔드 배포
#    buildspec.yml에서 s3 sync + cloudfront invalidation 실행
# ==============================================================================
resource "aws_codebuild_project" "frontend_deploy" {
  name          = "${var.project_name}-frontend-deploy"
  description   = "Deploy frontend build artifact to S3 and invalidate CloudFront cache"
  build_timeout = 10 # 분 (최소)
  service_role  = aws_iam_role.codebuild.arn

  # CodePipeline에서 아티팩트를 받습니다.
  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL" # 배포만 하므로 최소 사양으로 충분
    image                       = "aws/codebuild/standard:7.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"

    # buildspec.yml에서 참조하는 환경변수 주입
    environment_variable {
      name  = "FRONTEND_BUCKET"
      value = var.frontend_bucket_name
    }

    environment_variable {
      name  = "CLOUDFRONT_DISTRIBUTION_ID"
      value = var.cloudfront_distribution_id
    }
  }

  source {
    type = "CODEPIPELINE"
    # ZIP 내부의 buildspec.yml을 자동 탐색합니다.
    # (GitHub Actions가 buildspec.yml을 함께 패키징해야 합니다.)
    buildspec = "buildspec.yml"
  }

  # 빌드 로그를 CloudWatch Logs에 저장
  logs_config {
    cloudwatch_logs {
      group_name  = "/aws/codebuild/${var.project_name}-frontend-deploy"
      stream_name = "build-log"
      status      = "ENABLED"
    }
    s3_logs {
      status = "DISABLED"
    }
  }

  tags = {
    Name        = "${var.project_name}-frontend-deploy"
    Environment = var.environment
  }
}

# ==============================================================================
# 6. CodePipeline: 2단계 파이프라인
#    Stage 1 Source : S3 아티팩트 버킷에서 deployment.zip 감지
#    Stage 2 Deploy : CodeBuild로 배포 실행
# ==============================================================================
resource "aws_codepipeline" "frontend" {
  name     = "${var.project_name}-frontend-pipeline"
  role_arn = aws_iam_role.codepipeline.arn

  artifact_store {
    location = aws_s3_bucket.pipeline_artifact.bucket
    type     = "S3"
  }

  # ------------------------------------------------------------------
  # Stage 1: Source
  # GitHub Actions가 업로드한 deployment.zip을 S3에서 감지합니다.
  # PollForSourceChanges = true: 1분마다 S3 오브젝트 변경 여부 폴링
  # (운영 환경 권장: EventBridge + CloudTrail 방식으로 전환)
  # ------------------------------------------------------------------
  stage {
    name = "Source"

    action {
      name             = "S3Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "S3"
      version          = "1"
      output_artifacts = ["source_artifact"]

      configuration = {
        S3Bucket             = aws_s3_bucket.pipeline_artifact.bucket
        S3ObjectKey          = var.artifact_object_key
        PollForSourceChanges = "true"
      }
    }
  }

  # ------------------------------------------------------------------
  # Stage 2: Deploy
  # CodeBuild 프로젝트를 실행하여 S3 sync + CF invalidation 수행
  # ------------------------------------------------------------------
  stage {
    name = "Deploy"

    action {
      name            = "FrontendDeploy"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts = ["source_artifact"]

      configuration = {
        ProjectName = aws_codebuild_project.frontend_deploy.name
      }
    }
  }

  tags = {
    Name        = "${var.project_name}-frontend-pipeline"
    Environment = var.environment
  }
}
