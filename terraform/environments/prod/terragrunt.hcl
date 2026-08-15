include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "../..//"
}

inputs = {
  project_name     = "ToogleMaster-prod"
  region           = "us-east-1"
  db_password      = "ProdSenhaMasterSegura456#"
  create_iam_roles = true
  k8s_version      = "1.31"
}
