terraform {
  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = ">= 5.50, < 6.0"
      # WAF 로그 그룹은 us-east-1에 생성해야 하므로 alias 선언 필수
      configuration_aliases = [aws.us_east_1]
    }
  }
}
