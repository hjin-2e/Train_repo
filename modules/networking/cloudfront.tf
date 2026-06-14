# S3 버킷 (프론트엔드)
resource "aws_s3_bucket" "frontend" {
  bucket = "${var.project_name}-frontend"

  tags = {
    Name        = "${var.project_name}-frontend"
    Environment = var.environment
  }
}

# S3 버킷 서버 사이드 암호화
# AWS는 2023년부터 SSE-S3를 기본 적용하지만, 규정 준수 점검 시 명시적 선언이 없으면 미설정으로 판단될 수 있음
resource "aws_s3_bucket_server_side_encryption_configuration" "frontend" {
  bucket = aws_s3_bucket.frontend.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
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
  provider                          = aws.us_east_1
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

  # ALB 오리진 (백엔드 API) - 주소 및 환경에 따라 동적 생성
  dynamic "origin" {
    for_each = (var.environment == "prod" || var.alb_dns_name != "") ? [1] : []
    content {
      domain_name = var.environment == "prod" ? "api.team-train.cloud" : var.alb_dns_name
      origin_id   = "ALB-backend"

      custom_origin_config {
        http_port              = 80
        https_port             = 443
        origin_protocol_policy = var.environment == "prod" ? "https-only" : "http-only"
        origin_ssl_protocols   = ["TLSv1.2"]
      }
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  # prod만 도메인 연결 
  aliases = var.environment == "prod" ? [
    "team-train.cloud",
    "www.team-train.cloud"
  ] : []

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

  # API 경로 캐시 동작 (백엔드가 존재할 때만 동적 구성)
  dynamic "ordered_cache_behavior" {
    for_each = (var.environment == "prod" || var.alb_dns_name != "") ? [1] : []
    content {
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
  }

  # WAF 연동
  web_acl_id = aws_wafv2_web_acl.main.arn

  # SSL 인증서 (prod만 ACM, dev는 기본 인증서) 
  viewer_certificate {
    acm_certificate_arn            = var.environment == "prod" ? aws_acm_certificate.cloudfront[0].arn : null
    ssl_support_method             = var.environment == "prod" ? "sni-only" : null
    minimum_protocol_version       = var.environment == "prod" ? "TLSv1.2_2021" : null
    cloudfront_default_certificate = var.environment == "prod" ? false : true
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

  # prod 환경은 ACM 검증 완료 후 CloudFront 생성 (인증서 미검증 상태로 배포 방지)
  # count=0이면 빈 리스트로 평가되어 dev에서는 자동으로 의존성 없음
  depends_on = [aws_acm_certificate_validation.cloudfront]

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