aws_region           = "eu-central-1"
app_name             = "math-test-app"
container_port       = 3000
container_cpu        = 512
container_memory     = 1024
desired_count        = 2
ecr_repository_url   = "xxxxxxxxx.dkr.ecr.eu-central-1.amazonaws.com/math-test-app"  # Replace with your ECR URL