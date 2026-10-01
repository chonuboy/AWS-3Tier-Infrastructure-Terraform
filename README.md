# AWS 3-Tier Infrastructure with Terraform

Production-style three-tier AWS infrastructure provisioned using **Terraform** with modular Infrastructure as Code (IaC).

The project demonstrates how to design, provision, secure, and validate a highly available application infrastructure using AWS networking, load balancing, auto scaling, private application servers, managed database services, and IAM.

---

## 📌 Project Overview

This project provisions a three-tier architecture on AWS:

* **Web / Load Balancing Tier** — Application Load Balancer
* **Application Tier** — EC2 instances managed by an Auto Scaling Group
* **Database Tier** — Amazon RDS MySQL

The infrastructure is deployed across multiple Availability Zones using public and private subnets.

The application servers are placed in private subnets and receive internet access only through a NAT Gateway for outbound operations such as package installation and updates.

The project is fully provisioned using Terraform modules.

---

## 🏗️ Architecture

```text
                              Internet
                                  │
                                  ▼
                       ┌────────────────────┐
                       │ Internet Gateway   │
                       └──────────┬─────────┘
                                  │
                    ┌─────────────┴─────────────┐
                    │                           │
                    ▼                           ▼
             Public Subnet A              Public Subnet B
             ap-south-1a                  ap-south-1b
                    │                           │
                    └─────────────┬─────────────┘
                                  │
                                  ▼
                    ┌──────────────────────────┐
                    │ Application Load Balancer│
                    │         HTTP :80         │
                    └────────────┬─────────────┘
                                 │
                       Target Group :80
                                 │
                 ┌───────────────┴───────────────┐
                 │                               │
                 ▼                               ▼
          Private App Subnet A            Private App Subnet B
             ap-south-1a                    ap-south-1b
                 │                               │
                 ▼                               ▼
              EC2 #1                          EC2 #2
                 │                               │
                 └───────────────┬───────────────┘
                                 │
                         Private App Route Table
                                 │
                          0.0.0.0/0 → NAT
                                 │
                                 ▼
                           NAT Gateway
                                 │
                                 ▼
                       Internet Gateway
                                 │
                                 ▼
                              Internet


                 Application Tier
                        │
                   MySQL :3306
                        │
                        ▼
             ┌─────────────────────────┐
             │    Private DB Subnets  │
             │                         │
             │       RDS MySQL         │
             └─────────────────────────┘
```

---

## 🎯 Project Objectives

The main objectives of this project are:

* Build AWS infrastructure using Terraform
* Implement modular Terraform architecture
* Design public and private subnet architecture
* Deploy EC2 instances without public IPs
* Provide private instances with controlled outbound internet access using NAT Gateway
* Deploy an internet-facing Application Load Balancer
* Implement Auto Scaling for the application tier
* Implement security-group-based traffic isolation
* Deploy a private RDS MySQL database
* Use IAM roles instead of static AWS credentials on EC2
* Provision application servers automatically using user-data
* Validate ALB health checks
* Test Auto Scaling self-healing behavior
* Troubleshoot real AWS infrastructure failures

---

## 🛠️ Technologies Used

### Infrastructure as Code

* Terraform
* Terraform Modules
* Terraform Variables
* Terraform Outputs
* Terraform Data Sources
* Terraform Lifecycle Configuration

### AWS Services

* Amazon VPC
* Public & Private Subnets
* Internet Gateway
* NAT Gateway
* Elastic IP
* Route Tables
* Security Groups
* Application Load Balancer
* Target Groups
* EC2
* Launch Templates
* Auto Scaling Groups
* Amazon RDS MySQL
* IAM Roles
* IAM Instance Profiles
* AWS Systems Manager

### Operating System

* Amazon Linux 2023
* Apache HTTP Server

---

# 🌐 Network Architecture

## VPC

The project uses:

```text
VPC CIDR: 10.0.0.0/16
Region: ap-south-1
```

### Public Subnets

| Subnet   | CIDR        | Availability Zone |
| -------- | ----------- | ----------------- |
| public_a | 10.0.1.0/24 | ap-south-1a       |
| public_b | 10.0.2.0/24 | ap-south-1b       |

The public subnets host the Application Load Balancer and NAT Gateway.

### Private Application Subnets

| Subnet        | CIDR        | Availability Zone |
| ------------- | ----------- | ----------------- |
| private_app_a | 10.0.3.0/24 | ap-south-1a       |
| private_app_b | 10.0.4.0/24 | ap-south-1b       |

The EC2 application instances are deployed here.

### Private Database Subnets

| Subnet       | CIDR        | Availability Zone |
| ------------ | ----------- | ----------------- |
| private_db_a | 10.0.5.0/24 | ap-south-1a       |
| private_db_b | 10.0.6.0/24 | ap-south-1b       |

The RDS subnet group uses these private database subnets.

---

# 🔀 Routing Architecture

## Public Route Table

Public subnets use:

```text
0.0.0.0/0 → Internet Gateway
```

This provides internet connectivity for resources that require public access.

---

## Private Application Route Table

Application subnets use:

```text
0.0.0.0/0 → NAT Gateway
```

This allows private EC2 instances to initiate outbound internet connections without exposing them directly to the internet.

For example:

```text
EC2
 ↓
Private Route Table
 ↓
NAT Gateway
 ↓
Internet Gateway
 ↓
Internet
```

---

## Private Database Route Table

The database subnets do not have a default internet route.

This keeps the database tier isolated from direct internet access.

---

# 🔐 Security Architecture

Security Groups implement tier-to-tier traffic isolation.

```text
Internet
   │
   │ TCP :80
   ▼
ALB Security Group
   │
   │ TCP :80
   ▼
Application Security Group
   │
   │ TCP :3306
   ▼
Database Security Group
```

## ALB Security Group

Inbound:

```text
TCP 80
Source: 0.0.0.0/0
```

The ALB accepts HTTP traffic from the internet.

---

## Application Security Group

Inbound:

```text
TCP 80
Source: ALB Security Group
```

The EC2 instances do not accept HTTP traffic directly from the internet.

---

## Database Security Group

Inbound:

```text
TCP 3306
Source: Application Security Group
```

Only the application tier can communicate with the database on the MySQL port.

---

# ⚖️ Application Load Balancer

The project uses an internet-facing Application Load Balancer.

### Configuration

```text
Type: Application Load Balancer
Scheme: Internet-facing
Listener: HTTP :80
Target Type: Instance
Target Port: 80
```

The ALB is deployed across two public subnets in different Availability Zones.

Traffic is forwarded to the EC2 instances registered in the target group.

---

# ❤️ Health Checks

The target group performs HTTP health checks against:

```text
Path: /
Port: traffic-port
Protocol: HTTP
Success Codes: 200-299
```

The EC2 instances serve a static HTML page through Apache.

Example response:

```text
Hello World from ip-10-0-4-19.ap-south-1.compute.internal

3-Tier AWS Infrastructure

Application server is running successfully.

Managed by Terraform + Auto Scaling Group.
```

---

# 🚀 Auto Scaling Group

The application tier is managed using an Auto Scaling Group.

### Configuration

```text
Minimum Capacity: 2
Desired Capacity: 2
Maximum Capacity: 4
```

The instances are launched using a Terraform-managed Launch Template.

The ASG spans the two private application subnets:

```text
ap-south-1a → Private App Subnet A
ap-south-1b → Private App Subnet B
```

---

# 🔄 Auto Scaling & Self-Healing Validation

The Auto Scaling Group was manually tested for self-healing behavior.

### Test

One running EC2 instance was manually terminated.

The ASG detected that the number of running instances had fallen below the desired capacity.

It automatically launched a replacement instance.

The replacement instance:

1. Was launched using the Launch Template
2. Executed the user-data script
3. Installed Apache
4. Started the Apache service
5. Served the application page
6. Registered with the ALB Target Group
7. Passed the ALB health check
8. Became healthy

### Result

```text
EC2 Instance
     │
     ▼
Manual Termination
     │
     ▼
ASG Detects Capacity Loss
     │
     ▼
Replacement Instance
     │
     ▼
Launch Template
     │
     ▼
User Data
     │
     ▼
Apache
     │
     ▼
ALB Health Check
     │
     ▼
Healthy
```

**Result: Self-healing behavior successfully validated.**

---

# 🖥️ EC2 Application Provisioning

The EC2 instances use Amazon Linux 2023.

The application server is provisioned using Terraform Launch Template user-data.

```bash
#!/bin/bash

set -e

dnf update -y
dnf install -y httpd

systemctl enable httpd
systemctl start httpd

cat > /var/www/html/index.html <<EOF
<!DOCTYPE html>
<html>
<head>
    <title>3-Tier AWS Application</title>
</head>
<body>
    <h1>Hello World from $(hostname -f)</h1>
    <h2>3-Tier AWS Infrastructure</h2>
    <p>Application server is running successfully.</p>
    <p>Managed by Terraform + Auto Scaling Group.</p>
</body>
</html>
EOF
```

---

# 🗄️ Database Tier

The database tier uses Amazon RDS for MySQL.

### Configuration

```text
Engine: MySQL
Storage: 20 GB
Storage Type: gp3
Publicly Accessible: No
Encryption: Enabled
Database Subnets: Private DB Subnets
```

The RDS instance is not directly accessible from the internet.

Database access is restricted through the Database Security Group.

```text
EC2 Application Tier
        │
        │ TCP 3306
        ▼
     RDS MySQL
```

---

# 🔑 IAM

The EC2 instances use an IAM role through an instance profile.

The role includes:

```text
AmazonSSMManagedInstanceCore
```

This allows the instances to be managed through AWS Systems Manager without requiring SSH access from the public internet.

The project therefore avoids exposing port 22 on the application instances.

---

# 📁 Project Structure

```text
aws-3tier-infrastructure-terraform/
│
├── modules/
│   ├── vpc/
│   ├── subnet/
│   ├── networking/
│   ├── security-groups/
│   ├── alb/
│   ├── launch-template/
│   ├── asg/
│   ├── rds/
│   └── iam/
│
├── scripts/
│   └── app-user-data.sh
│
├── terraform/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── provider.tf
│   └── versions.tf
│
├── docs/
│
├── .gitignore
├── README.md
└── LICENSE
```

---

# 🧩 Terraform Modules

Each major infrastructure responsibility is separated into a Terraform module.

| Module            | Responsibility                                |
| ----------------- | --------------------------------------------- |
| `vpc`             | Creates the VPC                               |
| `subnet`          | Creates public/private subnets                |
| `networking`      | IGW, NAT Gateway and route tables             |
| `security-groups` | ALB, application and database security groups |
| `alb`             | Load balancer, listener and target group      |
| `launch-template` | EC2 AMI, instance configuration and user-data |
| `asg`             | Auto Scaling Group                            |
| `rds`             | RDS MySQL and DB subnet group                 |
| `iam`             | EC2 IAM role and instance profile             |

This modular structure makes the infrastructure easier to maintain, reuse and extend.

---

# 🚀 Deployment

## Prerequisites

Install:

* Terraform
* AWS CLI
* An AWS account
* Appropriate AWS credentials

Verify Terraform:

```bash
terraform version
```

Verify AWS CLI:

```bash
aws --version
```

Configure AWS credentials:

```bash
aws configure
```

---

## Clone the Repository

```bash
git clone 
cd aws-3tier-infrastructure-terraform
```

---

## Initialize Terraform

```bash
cd terraform
terraform init
```

---

## Format Configuration

```bash
terraform fmt -recursive
```

---

## Validate Configuration

```bash
terraform validate
```

Expected:

```text
Success! The configuration is valid.
```

---

## Review the Execution Plan

```bash
terraform plan
```

Always review the plan before applying infrastructure changes.

---

## Deploy

```bash
terraform apply
```

Confirm with:

```text
yes
```

Or simply:

```bash
terraform apply -auto-approve
```

---

## View Outputs

```bash
terraform output
```

Important outputs include:

* ALB DNS name
* VPC ID
* Subnet IDs
* Target Group ARN
* NAT Gateway ID
* RDS endpoint
* IAM role
* Instance profile

---

# 🧪 Validation

After deployment, validate the infrastructure in the following order.

### 1. Check EC2 instances

Verify that the ASG created the expected number of instances.

```text
Desired: 2
Running: 2
```

### 2. Check Target Group

Navigate to:

```text
EC2 → Target Groups → Targets
```

Both EC2 instances should eventually show:

```text
Healthy
```

### 3. Test ALB

Retrieve:

```bash
terraform output alb_dns_name
```

Open:

```text
http://<ALB-DNS-NAME>
```

Expected:

```text
Hello World from <hostname>
```

### 4. Test Auto Scaling

Terminate one EC2 instance manually.

The ASG should automatically launch a replacement.

Wait for the replacement to:

```text
Launch
   ↓
Bootstrap
   ↓
Apache
   ↓
Target Registration
   ↓
Health Check
   ↓
Healthy
```

---

# 🐛 Troubleshooting

During development, the initial ALB returned:

```text
502 Bad Gateway
```

and the target instances remained unhealthy.

The issue was investigated by tracing the complete request and provisioning path.

## Issue 1 — Missing NAT Route

The private application subnets were associated with the private application route table, but the route table did not initially contain:

```text
0.0.0.0/0 → NAT Gateway
```

Without this route, private EC2 instances could not reach the internet to download Apache packages.

The required routing path is:

```text
Private EC2
    ↓
Private Route Table
    ↓
NAT Gateway
    ↓
Internet Gateway
    ↓
Internet
```

Adding the NAT route restored outbound connectivity.

---

## Issue 2 — User-Data Configuration

The Launch Template initially contained a separate embedded user-data script instead of consistently using the script passed from the root configuration.

The Launch Template was corrected to load the external script:

```hcl
user_data = base64encode(
  file("${path.module}/../../scripts/app-user-data.sh")
)
```

The application script was also aligned with the Amazon Linux 2023 AMI:

```bash
dnf install -y httpd
```

instead of using Ubuntu's:

```bash
apt-get
```

or relying on a different operating system.

---

## Result

After correcting the networking and provisioning configuration:

```text
EC2 launched
      ↓
NAT connectivity
      ↓
Apache installation
      ↓
Apache started
      ↓
Port 80 available
      ↓
ALB health check
      ↓
Healthy
      ↓
Application accessible
```

---

# 🔒 Security Considerations

The project follows several security principles:

* EC2 instances are deployed in private subnets
* EC2 instances do not require public IP addresses
* ALB is the public entry point
* Application SG only accepts HTTP from the ALB SG
* Database SG only accepts MySQL from the application SG
* RDS is not publicly accessible
* IAM roles are used for EC2
* AWS Systems Manager can be used instead of exposing SSH
* Terraform variable files containing credentials are excluded from Git

---

# 💰 Cost Considerations

This project is designed as a learning/portfolio environment, not as a production deployment.

Resources such as:

* NAT Gateway
* Application Load Balancer
* RDS
* EC2
* Elastic IP

can incur AWS charges depending on the account, region, usage and current AWS pricing/free-tier eligibility.

When the infrastructure is not being used, destroy it:

```bash
terraform destroy
```

Always verify the AWS Console after destroying resources to ensure no billable resources remain.

---

# 🧹 Cleanup

To remove the infrastructure:

```bash
terraform destroy
```

Review the destruction plan and confirm:

```text
yes
```

After destruction, verify the AWS Console for any remaining resources.

---

# 📚 Key Concepts Demonstrated

This project provided practical experience with:

* Infrastructure as Code
* Terraform modules
* Terraform variables and outputs
* Terraform data sources
* VPC design
* CIDR planning
* Public vs private subnets
* Route tables
* Internet Gateway
* NAT Gateway
* Security Groups
* Application Load Balancer
* Target Groups
* Health checks
* Launch Templates
* Auto Scaling Groups
* Self-healing infrastructure
* EC2 user-data
* Amazon Linux
* RDS MySQL
* IAM roles
* Systems Manager
* Multi-AZ application architecture
* Infrastructure troubleshooting

---

# 🎯 Project Outcome

The final infrastructure successfully demonstrated:

```text
                    ┌───────────────┐
                    │    Internet   │
                    └───────┬───────┘
                            │
                            ▼
                    ┌───────────────┐
                    │      ALB      │
                    └───────┬───────┘
                            │
                 ┌──────────┴──────────┐
                 ▼                     ▼
             EC2 / ASG             EC2 / ASG
                 │                     │
                 └──────────┬──────────┘
                            │
                       NAT Gateway
                            │
                            ▼
                         Internet

                            │
                            ▼
                        RDS MySQL
```

The infrastructure was deployed using Terraform and validated through real AWS testing, including ALB traffic flow, EC2 provisioning, health checks and Auto Scaling self-healing.

---

# 🚀 Future Improvements

Potential future enhancements include:

* HTTPS with ACM certificates
* Route 53 custom domain
* CloudFront
* AWS WAF
* Secrets Manager for database credentials
* RDS Multi-AZ
* Two NAT Gateways for AZ-level NAT resilience
* CloudWatch monitoring and alarms
* Auto Scaling policies based on CPU utilization
* Terraform remote state using S3
* DynamoDB state locking
* CI/CD using GitHub Actions
* Separate development, staging and production environments
* Terraform environment/workspace strategy
* Containerized application deployment
* Amazon ECS or Kubernetes deployment

---

# 👨‍💻 Author

**Nanthakumar Krishnamoorthy**

DevOps / Cloud Engineering enthusiast focused on AWS, Terraform, Linux, Docker, CI/CD and cloud infrastructure automation.

---

## ⭐ If you found this project useful

Feel free to explore the repository and connect with me on GitHub and LinkedIn.