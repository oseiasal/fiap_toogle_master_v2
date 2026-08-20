include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../modules/secrets_manager"
}

inputs = {
  project_name = "ToogleMaster"
  environment  = "dev"
}
