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

// Definition of ECR repository
resource "aws_ecr_repository" "lamba" {
    name                 = var.name
    image_tag_mutability = "MUTABLE"

    image_scanning_configuration {
        scan_on_push = true
    }
    tags = {
        Team          = "${var.team}"
        Product       = "${var.product}"
        Department    = "${var.department}"
        Environment   = "${var.environment}"
    }
}

// Definition of ECR policy
resource "aws_ecr_lifecycle_policy" "lamba-policy" {
    repository = aws_ecr_repository.lamba.name

    policy = <<EOF
{
    "rules": [
        {
            "rulePriority": 1,
            "description": "Keep last 1 images untagged",
            "selection": {
                "tagStatus": "untagged",
                "countType": "imageCountMoreThan",
                "countNumber": 1
            },
            "action": {
                "type": "expire"
            }
        }
    ]
}
EOF
}