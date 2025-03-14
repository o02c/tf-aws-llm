data "aws_ssoadmin_instances" "this" {}

# -- administrator ---------------------------------------------------------------------------------
resource "aws_ssoadmin_permission_set" "administrator" {
  name             = "Administrator"
  instance_arn     = tolist(data.aws_ssoadmin_instances.this.arns)[0]
  session_duration = "PT12H"

  tags = {
    Privilege = "Administrator"
  }
}

resource "aws_ssoadmin_managed_policy_attachment" "administrator_access_for_administrator" {
  instance_arn       = tolist(data.aws_ssoadmin_instances.this.arns)[0]
  managed_policy_arn = data.aws_iam_policy.administrator_access.arn
  permission_set_arn = aws_ssoadmin_permission_set.administrator.arn
}

resource "aws_ssoadmin_account_assignment" "sandbox_on_administrator" {
  instance_arn       = aws_ssoadmin_permission_set.administrator.instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.administrator.arn

  principal_id   = aws_identitystore_group.this["administrator"].group_id
  principal_type = "GROUP"

  target_id   = data.aws_caller_identity.this.account_id
  target_type = "AWS_ACCOUNT"
}

# -- adminReadonly ---------------------------------------------------------------------------------
resource "aws_ssoadmin_permission_set" "admin_readonly" {
  name             = "AdminReadonly"
  instance_arn     = tolist(data.aws_ssoadmin_instances.this.arns)[0]
  session_duration = "PT12H"

  tags = {
    Privilege = "AdminReadonly"
  }
}

resource "aws_ssoadmin_managed_policy_attachment" "administrator_access_for_administrator" {
  instance_arn       = tolist(data.aws_ssoadmin_instances.this.arns)[0]
  managed_policy_arn = data.aws_iam_policy.admin_readonly.arn
  permission_set_arn = aws_ssoadmin_permission_set.admin_readonly.arn
}

resource "aws_ssoadmin_account_assignment" "sandbox_on_admin_readonly" {
  instance_arn       = aws_ssoadmin_permission_set.admin_readonly.instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.admin_readonly.arn

  principal_id   = aws_identitystore_group.this["admin_readonly"].group_id
  principal_type = "GROUP"

  target_id   = data.aws_caller_identity.this.account_id
  target_type = "AWS_ACCOUNT"
}
