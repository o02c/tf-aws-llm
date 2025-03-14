locals {
  aws_identitystore_group = {
    "administrator" = {
      description = "管理者グループ"
    }
    "admin_readonly" = {
      description = "管理者グループ(ReadOnly)"
    }
  }
}


resource "aws_identitystore_group" "this" {
  for_each = local.aws_identitystore_group

  identity_store_id = tolist(data.aws_ssoadmin_instances.this.identity_store_ids)[0]

  display_name = each.key
  description  = each.value.description
}
