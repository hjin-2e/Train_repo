# Azure MySQL Flexible Server 전체 도메인 주소
# DMS 타겟 엔드포인트 및 App Service 백엔드의 DB_HOST 환경변수로 사용
output "mysql_server_fqdn" {
  description = "Azure MySQL Flexible Server FQDN"
  value       = azurerm_mysql_flexible_server.dr.fqdn
}

output "mysql_server_name" {
  description = "Azure MySQL Flexible Server 이름"
  value       = azurerm_mysql_flexible_server.dr.name
}

output "mysql_server_id" {
  description = "Azure MySQL Flexible Server Resource ID"
  value       = azurerm_mysql_flexible_server.dr.id
}

output "mysql_database_name" {
  description = "생성된 데이터베이스 이름 (trail_db)"
  value       = azurerm_mysql_flexible_database.trail_db.name
}
