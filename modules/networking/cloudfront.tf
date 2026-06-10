# S3 버킷 (프론트엔드)
resource "aws_s3_bucket" "frontend" {
  bucket = "${var.project_name}-frontend"

  tags = {
    Name        = "${var.project_name}-frontend"
    Environment = var.environment
  }
}

# S3 버킷 퍼블릭 접근 차단
resource "aws_s3_bucket_public_access_block" "frontend" {
  bucket = aws_s3_bucket.frontend.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# CloudFront OAC (S3 접근 제어)
resource "aws_cloudfront_origin_access_control" "main" {
  provider = aws.us_east_1
  name                              = "${var.project_name}-oac"
  description                       = "S3 OAC"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# CloudFront 배포
resource "aws_cloudfront_distribution" "main" {
  provider = aws.us_east_1

  # S3 오리진 (프론트엔드)
  origin {
    domain_name              = aws_s3_bucket.frontend.bucket_regional_domain_name
    origin_id                = "S3-frontend"
    origin_access_control_id = aws_cloudfront_origin_access_control.main.id
  }

  # ALB 오리진 (백엔드 API)
  origin {
    domain_name = var.alb_dns_name
    origin_id   = "ALB-backend"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"
  # aliases = ["team-train.cloud", "www.team-train.cloud"]
  # ACM 검증 완료 후 주석 해제

  # 기본 캐시 동작 (프론트엔드)
  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "S3-frontend"
    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    min_ttl     = 0
    default_ttl = 3600
    max_ttl     = 86400
  }

  # API 경로 캐시 동작 (백엔드)
  ordered_cache_behavior {
    path_pattern           = "/api/*"
    allowed_methods        = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "ALB-backend"
    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      query_string = true
      headers      = ["Authorization"]
      cookies {
        forward = "all"
      }
    }

    min_ttl     = 0
    default_ttl = 0
    max_ttl     = 0
  }

  # WAF 연동
  web_acl_id = aws_wafv2_web_acl.main.arn

  # SSL 인증서
  # ACM 검증 완료 후 아래 주석 해제
  # viewer_certificate {
  #   acm_certificate_arn      = aws_acm_certificate.main.arn
  #   ssl_support_method       = "sni-only"
  #   minimum_protocol_version = "TLSv1.2_2021"
  # }

  # 임시 기본 인증서 사용
  viewer_certificate {
    cloudfront_default_certificate = true
  }

  # SPA 라우팅 (React)
  custom_error_response {
    error_code         = 403
    response_code      = 200
    response_page_path = "/index.html"
  }

  custom_error_response {
    error_code         = 404
    response_code      = 200
    response_page_path = "/index.html"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  # ACM 검증 완료 후 주석 해제
  # depends_on = [
  #   aws_acm_certificate_validation.main
  # ]

  tags = {
    Name        = "${var.project_name}-cf"
    Environment = var.environment
  }
}

# S3 버킷 정책 (CloudFront만 접근 허용)
resource "aws_s3_bucket_policy" "frontend" {
  bucket = aws_s3_bucket.frontend.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCloudFrontAccess"
        Effect = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action   = "s3:GetObject"
        Resource = "${aws_s3_bucket.frontend.arn}/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.main.arn
          }
        }
      }
    ]
  })
}


# #배포를 위해 일단 주석처리 하였는데 나중에 가비아 진행할 때는
#  # 이거 삭제 
# viewer_certificate {
#   cloudfront_default_certificate = true
# }

# # 이거 주석 해제 
# viewer_certificate {
#   acm_certificate_arn      = aws_acm_certificate.main.arn
#   ssl_support_method       = "sni-only"
#   minimum_protocol_version = "TLSv1.2_2021"
# }

# 나머지 주석처리한것들은 주석해제