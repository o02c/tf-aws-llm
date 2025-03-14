locals {
  aws_identitystore_user = {
    "sample@gmail.com" = {
      user_name = "sample"
      name = {
        family_name = "sample"
        given_name  = "sample"
      }
      group_ids = [
        aws_identitystore_group.this["administrator"].id
      ]
    }
  }
}

resource "aws_identitystore_user" "this" {
  for_each   = local.aws_identitystore_user
  depends_on = [aws_identitystore_group.this]

  identity_store_id = tolist(data.aws_ssoadmin_instances.this.identity_store_ids)[0]
  user_name         = each.value.user_name
  display_name      = "${each.value.name.family_name} ${each.value.name.given_name}"

  name {
    given_name  = each.value.name.given_name
    family_name = each.value.name.family_name
  }

  emails {
    value = each.key
    type  = "primary"
  }
}

module "identitystore_group_membership" {
  for_each = local.aws_identitystore_user

  source = "../modules/identitystore_group_membership"

  identity_store_id = tolist(data.aws_ssoadmin_instances.this.identity_store_ids)[0]

  member_id = aws_identitystore_user.this[each.key].user_id
  group_ids = local.aws_identitystore_user[each.key].group_ids
}
