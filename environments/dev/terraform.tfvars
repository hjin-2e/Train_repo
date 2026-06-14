aws_region    = "ap-northeast-2"
project_name  = "team-train"
environment   = "dev"
developer_ips = ["0.0.0.0/0"]



# DB 및 DMS 연동용 변수 설정
db_admin_user     = "admin"
db_admin_password = "Password123!"
azure_db_endpoint = "your-azure-db-name.mysql.database.azure.com" # Azure DB Endpoint 주소
azure_db_user     = "azure_admin_user"                            # Azure DB ID
azure_db_password = "azure_admin_password"                        # Azure DB PW

# 내부 알림용
notification_email       = "hjin201123@gmail.com"
verified_email_or_domain = "noreply@your-domain.com"
