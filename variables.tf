variable "cluster_name" {
  type        = string
  description = "Cluster name where the migration container will run."
}

variable "migration_container_name" {
  type        = string
  description = "Name of the container who is going to run the migration"
}

variable "override_template" {
  type        = map(any)
  description = "The override_template map."
}

variable "task_definition_arn" {
  type        = string
  description = "Original task definition arn, whose values from the override_template will take place."
}

variable "region" {
  type        = string
  description = "AWS region where the cluster is located"
}
