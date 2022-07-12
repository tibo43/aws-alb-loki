// Definition of provider version and backend
terraform {
    required_providers {
        aws = {
            source  = "hashicorp/aws"
            version = "~> 4.4"
        }
    }
   backend "s3" {  }
}

// Definition of provider and the region
provider "aws" {
    region = var.region
}

// Definition of IAM
module "iam" {
    source      = "./iam"
    for_each    = var.functions

    name        = each.key
    retention_in_days   = var.retention_in_days
    team        = each.value.team
    product     = each.value.product
    environment = each.value.environment
    department  = each.value.department
}
// Definition of Lambda
module "lambda" {
    source      = "./lambda"
    for_each    = var.functions

    name        = each.key
    role        = module.iam[each.key].arn
    image_uri   = var.image_uri
    source_code_hash    = var.source_code_hash
    timeout     = each.value.timeout
    memory_size = each.value.memory_size
    reserved_concurrent_executions  = var.reserved_concurrent_executions    
    variables   = each.value.variables
    maximum_event_age_in_seconds    = var.maximum_event_age_in_seconds
    maximum_retry_attempts          = var.maximum_retry_attempts
    team        = each.value.team
    product     = each.value.product
    environment = each.value.environment
    department  = each.value.department
    schedule    = each.value.schedule
    is_enabled  = each.value.is_enabled
}