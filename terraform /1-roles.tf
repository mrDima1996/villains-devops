#
#resource "aws_iam_user" "k8s_admin" {
#  name = "k8s_admin"
#
#  tags = merge(local.tags, {  tool = "EKS" })
#}
#
#resource "aws_iam_policy_attachment" "admin-attach" {
#  name       = "admin-attach"
#  users      = [aws_iam_user.k8s_admin.name]
#  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
#}

#resource "aws_iam_access_key" "k8s_admin" {
#  user = aws_iam_user.k8s_admin.name
#}
#
#resource "aws_secretsmanager_secret" "k8s_admin" {
#  name = "k8s_admin"
#}
#
#resource "aws_secretsmanager_secret_version" "k8s_admin" {
#  secret_id     = aws_secretsmanager_secret.k8s_admin.id
#  secret_string = aws_iam_access_key.k8s_admin.secret
#}