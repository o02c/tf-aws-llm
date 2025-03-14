data "aws_iam_policy" "administrator_access" {
  name = "AdministratorAccess"
}

data "aws_iam_policy" "admin_readonly" {
  name = "AdminReadonly"
}
