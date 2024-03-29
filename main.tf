terraform {
  required_providers {
    external = {
      source = "hashicorp/external"
     version = "~> 2.2.2"
    }
  }
}

data "external" "run_migration" {
  program = ["/bin/bash", "${path.module}/run-task.sh"]

  query = {
    region                   = var.region
    cluster_name             = var.cluster_name
    task_definition_arn      = var.task_definition_arn
    override_template        = base64encode(jsonencode(var.override_template))
    migration_container_name = var.migration_container_name
    assume_role_arn          = var.assume_role_arn
  }
}
