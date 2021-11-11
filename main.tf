//resource "null_resource" "run_migration" {
//  depends_on = [local_file.run-task]
//  triggers = {
//    run-task-content = timestamp()
//  }
//
//  provisioner "local-exec" {
//    command = "/bin/bash ${path.module}/run-task.sh"
//  }
//}
//output "test" {
//  value = {
//    region = var.region
//    cluster_name = var.cluster_name
//    task_definition_arn = var.task_definition_arn
//    override_template = base64encode(jsonencode(var.override_template))
//  }
//}

//resource "local_file" "run-task" {
//  //  depends_on = [
//  //    aws_ecs_task_definition.api
//  //  ]
//
//  filename = "${path.module}/run-task.sh"
//  content = templatefile("${path.module}/run-task.sh.tpl", {
//    cluster_name        = var.cluster_name
//    override_template   = jsonencode(var.override_template)
//    task_definition_arn = var.task_definition_arn
//    region              = var.region
//  })
//}
data "external" "run_migration" {
  program = ["/bin/bash", "${path.module}/run-task.sh"]

  query = {
    region                   = var.region
    cluster_name             = var.cluster_name
    task_definition_arn      = var.task_definition_arn
    override_template        = base64encode(jsonencode(var.override_template))
    migration_container_name = var.migration_container_name
  }
}
