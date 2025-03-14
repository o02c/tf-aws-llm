resource "aws_identitystore_group_membership" "this" {
  count = length(var.group_ids)

  identity_store_id = var.identity_store_id
  member_id         = var.member_id
  group_id          = replace(var.group_ids[count.index], "${var.identity_store_id}/", "")
}
