# Terraform module to run migration using ECS containers

This module uses the AWS API to start a new one-off ECS container, which overrides the command on a pre-existing task
definition to run a migration command, before the ECS service is updated.

This guarantees that one can build a new image to deploy live, and use the exact same to run the migration, given the
opportunity to abort the deploy if necessary.

## Dependencies
The aws-ecs-db-migration module works by placing an API calls to AWS and parsing their responses to check whether the migration worked.
Therefore, the following packages need to be installed on the machine that is running the terraform.

* [JQ](https://stedolan.github.io/jq/) 
* [AWS CLI version 2.0](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)

# How to use
Once you have defined your task definition create the migration resource with the proper configuration. Optionally, 
you can create a direct dependency to guarantee that the migration will only run after the task definition is created or updated.
``` terraform
module "db-migration" {
  depends_on = [
    aws_ecs_task_definition.api
  ]
  
  source  = "lmagalhaes/ecs-db-migration/aws"
  version = "~> 0.1.0"

  cluster_name             = "your-cluster"
  task_definition_arn      = "task-definition-arn"
  region                   = "ap-southeast-2"
  migration_container_name =  "container-name"
  override_template        = containerOverrides = [
    {
      name    = local.container_name
      command = ["/bin/bash", "-c", "migration command"]
    }
  ]
}
```

Then create a direct dependency to the ECS Service to ensure the service will only be updated it the migration succeed.

```terraform
  resource "aws_ecs_service" "default" {
  depends_on = [
    module.db-migration
  ]
  task_definition = aws_ecs_task_definition.default.arn
  ...
}
```

The run terraform

```bash
terraform init
terraform apply
```

[//]: # (BEGIN_TF_DOCS)
### Requirements

| Name | Version |
|------|---------|
| external | ~> 2.2.2 |

### Providers

| Name | Version |
|------|---------|
| external | 2.2.2 |

### Modules

No modules.

### Resources

| Name | Type |
|------|------|
| [external_external.run_migration](https://registry.terraform.io/providers/hashicorp/external/latest/docs/data-sources/external) | data source |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| override_template | The override_template map. For information about how to override a container definition check <a href='https://docs.aws.amazon.com/AmazonECS/latest/APIReference/API_ContainerOverride.html' target='_blank'>AWS ECS ContainerOverride documentation</a>. | `map(any)` | n/a | yes |
| assume_role_arn | [OPTIONAL] Allow role to be assumed before creating the ECS container. This is useful to allow running migrations CrossAccount. Defaults: '' | `string` | `""` | no |
| cluster_name | Cluster name where the migration will run. | `string` | n/a | yes |
| migration_container_name | Name to be given to the new migration container. | `string` | n/a | yes |
| region | Cluster AWS region | `string` | n/a | yes |
| task_definition_arn | ARN of the original task definition to use as base for the migration. | `string` | n/a | yes |

### Outputs

| Name | Description |
|------|-------------|
| response | n/a |
[//]: # (END_TF_DOCS)
