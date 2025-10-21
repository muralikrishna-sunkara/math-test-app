terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "eu-central-1"
}

variable "repository_name" {
  description = "ECR repository name"
  type        = string
  default     = "math-test-app"
}

variable "image_tag" {
  description = "Docker image tag"
  type        = string
  default     = "latest"
}

# Create ECR Repository
resource "aws_ecr_repository" "math_app" {
  name                 = var.repository_name
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = var.repository_name
  }
}

# ECR Repository Lifecycle Policy (optional - cleanup old images)
resource "aws_ecr_lifecycle_policy" "math_app" {
  repository = aws_ecr_repository.math_app.name

  policy = jsonencode({
    rules = [{
      rulePriority = 1
      description  = "Keep last 5 images"
      selection = {
        tagStatus     = "any"
        countType     = "imageCountMoreThan"
        countNumber   = 5
      }
      action = {
        type = "expire"
      }
    }]
  })
}

# Output values for pushing the image
output "repository_url" {
  description = "ECR repository URL"
  value       = aws_ecr_repository.math_app.repository_url
}

output "registry_id" {
  description = "AWS account ID (registry)"
  value       = aws_ecr_repository.math_app.registry_id
}

output "push_command" {
  description = "Docker push command to use"
  value       = "docker push ${aws_ecr_repository.math_app.repository_url}:${var.image_tag}"
}