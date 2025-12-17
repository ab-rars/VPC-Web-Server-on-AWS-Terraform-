provider "aws"{
  region = "ap-south-1"
  #1. hard core not safe
  # access_key = "AKIAxxxxxxxxxxxx"
  # secret_key = "abcdxxxxxxxxxxxx"

  #2. in case if store in terraform.tfvar
  # region     = var.region
  # access_key = var.access_key
  # secret_key = var.secret_key

}



data "aws_ami" "ubuntu_amd64" {
  owners      = ["099720109477"] # Canonical
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}


# 1. Create vpc
# 2. Create Internet Gateway
# 3. Create Custom Route Table
# 4. Create subnet
# 5. Associate subnet with Route Table
# 6. Ceate Security Group to allow port 22,30,443
# 7. Create a network interface with an ip in the subnet that was created in step 4
# 8. Assign an elastic IP to the network interface created in step 7
# 9. Create Ubuntu server and install/enable apache2


# 1. Create vpc
resource "aws_vpc" "first-vpc01" {
    cidr_block = "10.0.0.0/16"
    tags = {
        Name = "production-proj"
    }
}

# 2. Create Internet Gateway
resource "aws_internet_gateway" "ig-01" {
    vpc_id = aws_vpc.first-vpc01.id
    tags = {
        Name = "production-proj"
    }
}

# 3. Create Custom Route Table
resource "aws_route_table" "rt-01" {
  vpc_id = aws_vpc.first-vpc01.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ig-01.id
  }

  tags = {
    Name = "production-proj"
  }
}

# 4.Create subnet
resource "aws_subnet" "subnet-01" {
    vpc_id = aws_vpc.first-vpc01.id
    cidr_block = "10.0.1.0/24"
    availability_zone = "ap-south-1a"
    tags = {
        Name = "production-proj"
    }
}

# 5. Associate subnet with Route Table
resource "aws_route_table_association" "a" {
    subnet_id = aws_subnet.subnet-01.id
    route_table_id = aws_route_table.rt-01.id
}

# 6. Ceate Security Group to allow port 22,30,443
resource "aws_security_group" "allow_web" {
  name        = "allow_web_traffic"
  description = "Allow Web inbound traffic"
  vpc_id      = aws_vpc.first-vpc01.id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # ingress {
  #   description = "HTTPS"
  #   from_port   = 443
  #   to_port     = 443
  #   protocol    = "tcp"
  #   cidr_blocks = ["0.0.0.0/0"]
  # }
  ingress {
    description = "ssh"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
        Name = "production-proj"
    }
}

# 7. Create a network interface with an ip in the subnet that was created in step 4
resource "aws_network_interface" "web_server_nic" {
    subnet_id = aws_subnet.subnet-01.id
    private_ips = ["10.0.1.100"]
    security_groups = [ aws_security_group.allow_web.id ]
}

# 8. Assign an elastic IP to the network interface created in step 7
resource "aws_eip" "one" {
  domain = "vpc"
  network_interface = aws_network_interface.web_server_nic.id
  associate_with_private_ip = "10.0.1.100"
  depends_on = [aws_internet_gateway.ig-01]
}

# just for knowledge after running the terrofrm this will print the public-ip of eip in the end of the console
output "server_public_ip" {
  value = aws_eip.one.public_ip
}

#9. 
resource "aws_instance" "web_server_instance" {
  ami           = data.aws_ami.ubuntu_amd64.id
  instance_type = "t3.micro"
  availability_zone = "ap-south-1a"
  key_name = "mynewkey"

  # network_interface {
  #   device_index = 0
  #   network_interface_id = aws_network_interface.web-server-nic.id
  # }
  network_interface {
  device_index         = 0
  network_interface_id = aws_network_interface.web_server_nic.id
}
  user_data = <<-EOF
              #!/bin/bash
              sudo apt update -y
              sudo apt install apache2 -y
              sudo systemctl start apache2
              sudo bash -c 'echo site from the terraform code > /var/www/html/index.html'
              EOF
 tags = {
    Name = "production-proj"
  }
}

