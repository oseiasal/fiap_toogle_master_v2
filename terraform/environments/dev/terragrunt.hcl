include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "../..//"
}

inputs = {
  project_name     = "ToogleMaster-dev"
  region           = "us-east-1"
  db_password      = "DevSenhaMaster123!"
  create_iam_roles = true
  k8s_version      = "1.31"
}
