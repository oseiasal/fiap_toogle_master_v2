resource "aws_ecr_repository" "services" {
  for_each = toset(var.services)

  name                 = each.key
  image_tag_mutability = var.image_tag_mutability
  force_delete         = var.force_delete

  image_scanning_configuration {
    scan_on_push = var.scan_on_push
  }

  tags = {
    Project = var.project_name
  }
}
