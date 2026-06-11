aws_region    = "ap-northeast-2"
project_name  = "team-train"
environment   = "dev"
developer_ips = ["0.0.0.0/0"]

# 첫 배포를 위한 더미 값
cloudfront_domain_name = "dummy-cf.cloudfront.net"
cloudfront_zone_id     = "Z2FDTNDATAQYW2"
alb_dns_name           = "dummy-alb.ap-northeast-2.elb.amazonaws.com"
alb_zone_id            = "Z3POXM214Y7URM"

# DB 및 DMS 연동용 변수 설정
db_admin_user     = "admin"
db_admin_password = ""
azure_db_endpoint = "your-azure-db-name.mysql.database.azure.com" # Azure DB Endpoint 주소
azure_db_user     = "azure_admin_user"                            # Azure DB ID
azure_db_password = "azure_admin_password"                        # Azure DB PW

# 내부 알림용
notification_email       = "hjin201123@gmail.com"
verified_email_or_domain = "noreply@your-domain.com"
