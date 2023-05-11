# Terraform script to create a service on the cloud
# Let's set up our cloud provider with Terraform

# Who is the provider - AWS
# How to codify with terraform - syntax - name of the resource/task {key = value}
# most commonly used commands - terraform init - terraform plan - terraform apply - terraform destroy


provider "aws" {

	region = "eu-west-1"

}

# Create a service on AWS

# Create a VPC on AWS

resource "aws_vpc" "tech221_oleg_terraform_vpc" {
  cidr_block = var.cidr_block
  instance_tenancy = "default"

  tags = {
    Name = "tech221_oleg_terraform_vpc"
  }
}

# create a Gateway on AWS
resource "aws_internet_gateway" "tech221_oleg_terraform_gw" {
  vpc_id = aws_vpc.tech221_oleg_terraform_vpc.id

  tags = {
    Name = "tech221_oleg_terraform_gw"
  }
}

# Create a public route table on AWS
resource "aws_route_table" "tech221_oleg_publicRT" {
  #default_route_table_id = aws_vpc.tech221_oleg_publicRT.default_route_table_id	
  vpc_id = aws_vpc.tech221_oleg_terraform_vpc.id

  #route {
    #cidr_block = var.cidr_block
    #gateway_id = aws_internet_gateway.tech221_oleg_terraform_gw.id
  #}

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.tech221_oleg_terraform_gw.id
  }

  tags = {
    Name = "oleg_publicRT"
  }
}


# Create a private route table on AWS
resource "aws_route_table" "tech221_oleg_privateRT" {
  #default_route_table_id = aws_vpc.tech221_oleg_privateRT.default_route_table_id	
  vpc_id = aws_vpc.tech221_oleg_terraform_vpc.id

  #route {
    #cidr_block = var.cidr_block
    #gateway_id = aws_internet_gateway.tech221_oleg_terraform_gw.id
  #}

  tags = {
    Name = "oleg_privateRT"
  }
}

# Create a Public Subnet in VPC

resource "aws_subnet" "tech221_oleg_publicSubnet" {
	vpc_id = aws_vpc.tech221_oleg_terraform_vpc.id
	cidr_block = var.public_subnet_cidr_block
	map_public_ip_on_launch = "true"
	availability_zone = var.availability_zone

	tags = {
		Name = "tech221_oleg_publicSubnet"
	}

}


# Create a Private Subnet in VPC

resource "aws_subnet" "tech221_oleg_privateSubnet" {
	vpc_id = aws_vpc.tech221_oleg_terraform_vpc.id
	cidr_block = var.private_subnet_cidr_block
	availability_zone = var.availability_zone

	tags = {
		Name = "tech221_oleg_privateSubnet"
	}

}


# Creating Route association public Subnet

resource "aws_route_table_association" "oleg_public_association" {
	subnet_id = aws_subnet.tech221_oleg_publicSubnet.id
	route_table_id = aws_route_table.tech221_oleg_publicRT.id
}


# Creating Route association private Subnet

resource "aws_route_table_association" "oleg_private_association" {
	subnet_id = aws_subnet.tech221_oleg_privateSubnet.id
	route_table_id = aws_route_table.tech221_oleg_privateRT.id
}

# Create a security group for App EC2

resource "aws_security_group" "tech221_oleg_AppSG" {
  name        = "security group for App"
  description = "security group for App"
  vpc_id      = aws_vpc.tech221_oleg_terraform_vpc.id

  ingress {
    description      = "HTTP"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  #ingress {
    #description      = "SSH"
    #from_port        = 22
    #to_port          = 22
    #protocol         = "tcp"
    #cidr_blocks      = ["0.0.0.0/0"]
    #ipv6_cidr_blocks = ["::/0"]
  #}

  ingress {
    description      = "port3000"
    from_port        = 3000
    to_port          = 3000
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "tech221_oleg_AppSG"
  }
}

# which service - EC2

resource "aws_instance" "app_instance"{
	# which ami to use
	ami = var.aim_id
	
	#type of instance
	instance_type = "t2.micro"

	# do you need the public IP
	associate_public_ip_address = true

	# Which subnet

	subnet_id = "${aws_subnet.tech221_oleg_publicSubnet.id}"

	# Add security groups

	security_groups = ["${aws_security_group.tech221_oleg_AppSG.id}"]

	# what would you like to name it
	tags = {
	
	  Name = "tech221_oleg_terraform_app"

	} 

}



