import sys
path = r'c:\Users\soldesk\Desktop\last repo\tera.12\Train_repo\modules\infra\eks-addons\main.tf'
with open(path, 'r', encoding='utf-8') as f:
    text = f.read()

text = text.replace('resource "kubernetes_cluster_role" "developer" {', 'resource "kubernetes_cluster_role_v1" "developer" {')
text = text.replace('resource "kubernetes_cluster_role_binding" "developer" {', 'resource "kubernetes_cluster_role_binding_v1" "developer" {')
text = text.replace('name      = kubernetes_cluster_role.developer.metadata[0].name', 'name      = kubernetes_cluster_role_v1.developer.metadata[0].name')
text = text.replace('resource "kubernetes_service_account" "booking" {', 'resource "kubernetes_service_account_v1" "booking" {')
text = text.replace('resource "kubernetes_service_account" "user" {', 'resource "kubernetes_service_account_v1" "user" {')
text = text.replace('resource "kubernetes_service_account" "payment" {', 'resource "kubernetes_service_account_v1" "payment" {')

added = '''
moved {
  from = kubernetes_service_account.booking
  to   = kubernetes_service_account_v1.booking
}

moved {
  from = kubernetes_service_account.user
  to   = kubernetes_service_account_v1.user
}

moved {
  from = kubernetes_service_account.payment
  to   = kubernetes_service_account_v1.payment
}
'''

if 'moved {' not in text:
    text += added

with open(path, 'w', encoding='utf-8') as f:
    f.write(text)
print('Done!')
