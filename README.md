# Math Test App - AWS ECS Fargate Deployment

A highly available, production-ready deployment of a kids' math test application on AWS ECS Fargate using Terraform Infrastructure as Code.

## Overview

This project demonstrates how to deploy a Node.js application (`muralidockertest/math-test-app:2.0`) on AWS using modern cloud infrastructure patterns with high availability, auto-scaling, and load balancing.

## Architecture

### Infrastructure Components

- **AWS ECS Fargate**: Serverless container orchestration
- **Application Load Balancer (ALB)**: Distributes traffic across multiple availability zones
- **VPC**: Custom Virtual Private Cloud with public and private subnets
- **Multi-AZ Deployment**: Resources distributed across 2 availability zones for high availability
- **NAT Gateways**: Enable private subnet instances to access the internet
- **Auto Scaling**: Automatic scaling based on CPU and memory utilization
- **CloudWatch**: Centralized logging and monitoring

### Network Architecture

```
Internet
    |
    v
Application Load Balancer (Public Subnets)
    |
    v
ECS Fargate Tasks (Private Subnets)
    |
    v
NAT Gateways (for outbound traffic)
```

#### VPC Configuration
- **VPC CIDR**: 10.0.0.0/16
- **Public Subnets**:
  - 10.0.1.0/24 (AZ-1)
  - 10.0.2.0/24 (AZ-2)
- **Private Subnets**:
  - 10.0.10.0/24 (AZ-1)
  - 10.0.11.0/24 (AZ-2)

### High Availability Features

1. **Multi-AZ Deployment**: Tasks run in 2 different availability zones
2. **Dual NAT Gateways**: One per AZ for redundancy
3. **Load Balancer**: Distributes traffic and performs health checks
4. **Auto Scaling**:
   - Min: 2 tasks
   - Max: 4 tasks
   - CPU threshold: 70%
   - Memory threshold: 80%

## Application Details

- **Container Image**: `muralidockertest/math-test-app:2.0`
- **Port**: 3000
- **Resources**:
  - CPU: 512 (0.5 vCPU)
  - Memory: 1024 MB (1 GB)
- **Desired Count**: 2 tasks (for HA)

## Prerequisites

- AWS Account with appropriate permissions
- Terraform >= 1.0
- AWS CLI configured
- Docker Hub access (for pulling the math-test-app image)

## Project Structure

```
math-test-app/
├── main.tf           # Provider configuration and ECR repository
├── ecs.tf            # ECS cluster, services, VPC, ALB, and networking
├── terraform.tfvars  # Variable values
└── README.md         # This file
```

## Deployment Instructions

### 1. Configure AWS Credentials

```bash
aws configure
# Enter your AWS Access Key ID, Secret Access Key, and default region
```

### 2. Update Variables

Edit `terraform.tfvars` and update the ECR repository URL with your AWS account ID:

```hcl
ecr_repository_url = "YOUR_ACCOUNT_ID.dkr.ecr.eu-central-1.amazonaws.com/math-test-app"
```

### 3. Initialize Terraform

```bash
terraform init
```

### 4. Review the Plan

```bash
terraform plan
```

### 5. Deploy Infrastructure

```bash
terraform apply
```

Type `yes` when prompted to confirm the deployment.

### 6. Access the Application

After deployment completes, Terraform will output the load balancer URL:

```bash
terraform output load_balancer_url
```

Visit the URL in your browser to access the math test app.

## Infrastructure Resources

### Networking
- 1 VPC
- 1 Internet Gateway
- 2 Public Subnets
- 2 Private Subnets
- 2 NAT Gateways
- 2 Elastic IPs
- 3 Route Tables (1 public, 2 private)
- 2 Security Groups

### Compute
- 1 ECS Cluster with Container Insights enabled
- 1 ECS Task Definition
- 1 ECS Service
- 2-4 ECS Tasks (auto-scaled)

### Load Balancing
- 1 Application Load Balancer
- 1 Target Group
- 1 HTTP Listener (Port 80)

### Monitoring & Logging
- 1 CloudWatch Log Group (7-day retention)
- Auto Scaling Policies (CPU and Memory)

### IAM
- 1 ECS Task Execution Role
- Role Policy Attachment

## Security Features

### Security Groups

1. **ALB Security Group**:
   - Inbound: HTTP (80), HTTPS (443) from anywhere
   - Outbound: All traffic

2. **ECS Tasks Security Group**:
   - Inbound: Port 3000 from ALB only
   - Outbound: All traffic

### Network Security
- ECS tasks run in private subnets (no direct internet access)
- Outbound internet access via NAT Gateways
- ALB in public subnets for internet-facing access

## Auto Scaling Configuration

### CPU-based Scaling
- Target: 70% CPU utilization
- Scales up when average CPU exceeds 70%
- Scales down when CPU drops below 70%

### Memory-based Scaling
- Target: 80% memory utilization
- Scales up when average memory exceeds 80%
- Scales down when memory drops below 80%

### Scaling Limits
- Minimum: 2 tasks
- Maximum: 4 tasks

## Monitoring

### CloudWatch Logs
All container logs are sent to CloudWatch Logs:
- Log Group: `/ecs/math-test-app`
- Retention: 7 days
- Stream Prefix: `ecs`

### Container Insights
ECS Container Insights is enabled for enhanced monitoring of:
- Task and service performance
- Resource utilization
- Container metrics

## Health Checks

The Application Load Balancer performs health checks:
- **Path**: `/`
- **Interval**: 30 seconds
- **Timeout**: 3 seconds
- **Healthy Threshold**: 2 consecutive successes
- **Unhealthy Threshold**: 2 consecutive failures
- **Success Code**: 200

## Outputs

After deployment, the following outputs are available:

```bash
terraform output load_balancer_dns      # ALB DNS name
terraform output load_balancer_url      # Full HTTP URL
terraform output ecs_cluster_name       # ECS cluster name
terraform output ecs_service_name       # ECS service name
```

## Cost Considerations

### Primary Cost Components
1. **ECS Fargate Tasks**: ~$0.04/hour per task (2-4 tasks)
2. **NAT Gateways**: ~$0.045/hour × 2 = $0.09/hour
3. **Application Load Balancer**: ~$0.0225/hour
4. **Data Transfer**: Variable based on usage
5. **CloudWatch Logs**: Based on ingestion and storage

**Estimated Monthly Cost**: ~$100-150 USD (varies by region and usage)

## Cleanup

To destroy all resources and avoid charges:

```bash
terraform destroy
```

Type `yes` when prompted to confirm deletion.

## Troubleshooting

### Check ECS Service Status
```bash
aws ecs describe-services \
  --cluster math-test-app-cluster \
  --services math-test-app-service \
  --region eu-central-1
```

### View Container Logs
```bash
aws logs tail /ecs/math-test-app --follow --region eu-central-1
```

### Check Task Status
```bash
aws ecs list-tasks \
  --cluster math-test-app-cluster \
  --region eu-central-1
```

### Common Issues

1. **Tasks not starting**: Check CloudWatch logs for errors
2. **Health checks failing**: Verify container is listening on port 3000
3. **Cannot access ALB**: Check security group rules
4. **High costs**: Review NAT Gateway usage and consider alternatives

## Production Recommendations

### Security Enhancements
- [ ] Enable HTTPS with ACM certificate
- [ ] Implement WAF rules on ALB
- [ ] Enable VPC Flow Logs
- [ ] Use AWS Secrets Manager for sensitive data
- [ ] Implement least-privilege IAM policies

### High Availability
- [ ] Deploy across 3+ availability zones
- [ ] Implement automated backups if using databases
- [ ] Configure Route53 health checks
- [ ] Set up CloudWatch alarms for critical metrics

### Performance
- [ ] Enable ALB access logs
- [ ] Configure CloudFront CDN for static assets
- [ ] Implement container image scanning
- [ ] Optimize container image size

### Monitoring
- [ ] Set up CloudWatch dashboards
- [ ] Configure SNS notifications for alarms
- [ ] Implement distributed tracing (AWS X-Ray)
- [ ] Set up log aggregation and analysis

## Contributing

Feel free to submit issues or pull requests for improvements.

## License

This infrastructure code is provided as-is for educational and demonstration purposes.

---

**Author**: Infrastructure as Code demonstration
**Last Updated**: 2025
**Region**: eu-central-1 (Frankfurt)