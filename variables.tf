variable "cluster_name" {
  type        = string
  description = "Cluster name where the migration will run."
}

variable "migration_container_name" {
  type        = string
  description = "Name to be given to the new migration container."
}

variable "override_template" {
  type        = map(any)
  description = "The override_template map. For information about how to override a container definition check <a href='https://docs.aws.amazon.com/AmazonECS/latest/APIReference/API_ContainerOverride.html' target='_blank'>AWS ECS ContainerOverride documentation</a>."
}

variable "task_definition_arn" {
  type        = string
  description = "ARN of the original task definition to use as base for the migration."
}

variable "region" {
  type        = string
  description = "Cluster AWS region"
}
