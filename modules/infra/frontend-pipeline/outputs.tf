# ==================
# S3 아티팩트 버킷
# ==================
output "pipeline_artifact_bucket_name" {
  description = "CodePipeline 아티팩트 S3 버킷 이름. GitHub Secrets의 ARTIFACT_BUCKET에 등록하세요."
  value       = aws_s3_bucket.pipeline_artifact.bucket
}

output "pipeline_artifact_bucket_arn" {
  description = "CodePipeline 아티팩트 S3 버킷 ARN"
  value       = aws_s3_bucket.pipeline_artifact.arn
}

# ==================
# GitHub Actions IAM Role
# ==================
output "github_actions_role_arn" {
  description = <<EOT
GitHub Actions가 수임할 IAM Role ARN.
GitHub Repository Secrets에 AWS_GITHUB_ACTIONS_ROLE_ARN 이름으로 등록하세요.
EOT
  value       = aws_iam_role.github_actions.arn
}

# ==================
# CodePipeline
# ==================
output "codepipeline_name" {
  description = "CodePipeline 파이프라인 이름"
  value       = aws_codepipeline.frontend.name
}

output "codepipeline_arn" {
  description = "CodePipeline 파이프라인 ARN"
  value       = aws_codepipeline.frontend.arn
}

# ==================
# CodeBuild
# ==================
output "codebuild_project_name" {
  description = "CodeBuild 프로젝트 이름"
  value       = aws_codebuild_project.frontend_deploy.name
}

output "codebuild_project_arn" {
  description = "CodeBuild 프로젝트 ARN"
  value       = aws_codebuild_project.frontend_deploy.arn
}
