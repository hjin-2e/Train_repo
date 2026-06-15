variable "project_name" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Deployment environment (dev / prod)"
  type        = string
}

variable "gitops_repo_url" {
  description = "ArgoCD가 감시할 깃허브 레포지토리 URL (예: https://github.com/hjin-2e/Train_repo.git)"
  type        = string
  default     = "https://github.com/hjin-2e/Train_repo.git"
}
