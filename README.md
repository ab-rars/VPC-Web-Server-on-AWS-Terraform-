# VPC-Web-Server-on-AWS-Terraform-
Automated AWS VPC + EC2 (Apache) deployment using Terraform.

This Terraform project automates AWS infrastructure deployment for a public web server. It provisions a complete VPC setup and launches an Ubuntu 22.04 EC2 instance (t3.micro, Free Tier) with Apache installed automatically — demonstrating practical Infrastructure as Code (IaC) skills.

## What It Does
- Creates a **VPC (10.0.0.0/16)**, **Subnet (10.0.1.0/24)**, **Internet Gateway**, and **Route Table**
- Associates subnet with route table for internet access
- Builds a **Security Group** (Inbound: 22, 80 / Outbound: all)
- Creates a **Network Interface (10.0.1.100)** and attaches an **Elastic IP**
- Launches **Ubuntu 22.04 EC2 instance** using Canonical’s latest AMI
- Runs a **user_data Bash script** to install and start Apache2:
  - Updates packages, installs Apache, and serves a default page with text:
    `site from the terraform code`
- Outputs the **public IP** of the instance after deployment

## Usage
aws configure                        # Configure AWS credentials  
terraform init                       # Initialize Terraform  
terraform plan                       # Preview infrastructure changes  
terraform apply                      # Create all AWS resources  
terraform output server_public_ip    # Get Elastic IP  
terraform destroy                    # Clean up after testing  

## Key Details
Region: ap-south-1 (Mumbai)  
Instance Type: t3.micro (Free Tier eligible)  
AMI: Latest Ubuntu 22.04 LTS (Jammy) from Canonical  
Key Pair: mynewkey (edit if using a different name)  
Output: Public IP printed after apply, accessible via browser  

## Security & Best Practices
- Never commit `terraform.tfvars`, `.tfstate`, or `.pem` files  
- Restrict SSH (port 22) to your own IP in production  
- Use `aws configure` or environment variables for credentials  
- Add `.terraform/` and sensitive files to `.gitignore`  

## Example Output
Apply complete!  
Outputs:  
server_public_ip = 13.xx.xx.xx  

Visit: http://13.xx.xx.xx → displays **“site from the terraform code”**

## Author
Abrar Syed — Cloud & DevOps Engineer  
Skilled in AWS | Terraform | CI/CD | Docker | Kubernetes | Cloud Automation
