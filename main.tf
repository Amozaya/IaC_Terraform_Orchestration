# Terraform script to create a service on the cloud
# Let's set up our cloud provider with Terraform

# Who is the provider - AWS
# How to codify with terraform - syntax - name of the resource/task {key = value}
# most commonly used commands - terraform init - terraform plan - terraform apply - terraform destroy


provider "aws" {

	region = "eu-west-1"

}

# Create a service on AWS
# which service - EC2

resource "aws_instance" "app_instance"{
	# which ami to use
	ami = "ami-064b12715525b93e0"
	
	#type of instance
	instance_type = "t2.micro"

	# do you need the public IP
	associate_public_ip_address = true

	# what would you like to name it
	tags = {
	
	  Name = "tech221_oleg_terraform_app"

	} 

}

