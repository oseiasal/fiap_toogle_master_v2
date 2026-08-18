include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../modules/ecr"
}

inputs = {
  project_name         = "ToogleMaster"
  image_tag_mutability = "MUTABLE"
  scan_on_push         = true
  force_delete         = true

  services = [
    "analytics-service",
    "auth-service",
    "evaluation-service",
    "flag-service",
    "targeting-service"
  ]
}
