# https://registry.terraform.io/providers/hashicorp/aws/latest/docs
# In windows:
#  set "AWS_ACCESS_KEY_ID=NNNNNNNNNNNNNNNNNNNNNNNNNNN"
#  set "AWS_SECRET_ACCESS_KEY=NNNNNNNNNNNNNNNNNNNNNNNNNNN"


variable "private_key_path" {
  type = string  
}

variable "my_access_key" {
  type = string  
}

variable "my_secret_key" {
  type = string  
}

variable "my_region" {
  type = string  
}

variable "my_jenkins_ami" {
  type = string  
}

variable "my_jenkins_instance_type" {
  type = string  
}
variable "my_aws_key_name" {
  type = string  
}

variable "my_jenkins_internal_IP" {
  type = string  
}




terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region     = var.my_region
  access_key = var.my_access_key
  secret_key = var.my_secret_key
}

#Creatin my own VPC in a range of 10.10.96.0 - 10.10.111.255
resource "aws_vpc" "terravpc" {
  cidr_block = "10.10.100.0/22"
  enable_dns_support = "true"
  enable_dns_hostnames = "true"  
  instance_tenancy = "default"
  
  tags = {
    Name = "terravpc"
  }  
}


#This allow internet gateway
resource "aws_internet_gateway" "terravpc-igw" {
    vpc_id = "${aws_vpc.terravpc.id}"
    tags = {
        Name = "terravpc-igw"
    }
}

#Route table to internet access
resource "aws_route_table" "terravpc-rtb-public" {
    vpc_id = "${aws_vpc.terravpc.id}"
    
    route {
        //associated subnet can reach everywhere
        cidr_block = "0.0.0.0/0" 
        //CRT uses this IGW to reach internet
        gateway_id = "${aws_internet_gateway.terravpc-igw.id}" 
    }
    
    tags = {
        Name = "terravpc-rtb-public"
    }
}


#Route table association for internet
resource "aws_route_table_association" "terravpc-rta-public-us-east-1a"{
    subnet_id = "${aws_subnet.terravpc-subnet-public-us-east-1a.id}"
    route_table_id = "${aws_route_table.terravpc-rtb-public.id}"
}



#Expose public subnet range 10.10.100.0 - 10.10.100.127
resource "aws_subnet" "terravpc-subnet-public-us-east-1a" {
  vpc_id = "${aws_vpc.terravpc.id}"
  cidr_block = "10.10.100.0/25"
  map_public_ip_on_launch = "true"
  availability_zone = "us-east-1a"
  
  tags = {
    Name = "terravpc-subnet-public-us-east-1a"
  }  
  
}

#Expose private subnet range 10.10.100.128 - 10.10.100.255
resource "aws_subnet" "terravpc-subnet-private-us-east-1a" {
  vpc_id = "${aws_vpc.terravpc.id}"
  cidr_block = "10.10.100.128/25"  
  availability_zone = "us-east-1a"
  
  tags = {
    Name = "terravpc-subnet-private-us-east-1a"
  }  
  
}

#Expose public subnet range 10.10.101.0 - 10.10.101.127
resource "aws_subnet" "terravpc-subnet-public-us-east-1b" {
  vpc_id = "${aws_vpc.terravpc.id}"
  cidr_block = "10.10.101.0/25"
  map_public_ip_on_launch = "true"
  availability_zone = "us-east-1b"
  
  tags = {
    Name = "terravpc-subnet-public-us-east-1b"
  }  
  
}

#Expose private subnet range 10.10.101.128 - 10.10.101.255
resource "aws_subnet" "terravpc-subnet-private-us-east-1b" {
  vpc_id = "${aws_vpc.terravpc.id}"
  cidr_block = "10.10.101.128/25"  
  availability_zone = "us-east-1b"
  
  tags = {
    Name = "terravpc-subnet-private-us-east-1b"
  }  
  
}

resource "aws_security_group" "ssh-allowed" {
    vpc_id = "${aws_vpc.terravpc.id}"
    
    egress {
        from_port = 0
        to_port = 0
        protocol = -1
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        // This means, all ip address are allowed to ssh ! 
        // Do not do it in the production. 
        // Put your office or home address in it!
        cidr_blocks = ["0.0.0.0/0"]
    }
    //If you do not add this rule, you can not reach the NGIX  
    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
	
	ingress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
	
    tags = {
        Name = "ssh-allowed"
    }
}


resource "aws_security_group" "jenkins-allowed" {
    vpc_id = "${aws_vpc.terravpc.id}"
    
    egress {
        from_port = 0
        to_port = 0
        protocol = -1
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 8080
        to_port = 8080
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    
    tags = {
        Name = "jenkins-allowed"
    }
}

resource "aws_network_interface" "MyNetworkInterface_01" {
  subnet_id = "${aws_subnet.terravpc-subnet-public-us-east-1a.id}"
  private_ips = [var.my_jenkins_internal_IP]
  security_groups = ["${aws_security_group.ssh-allowed.id}","${aws_security_group.jenkins-allowed.id}"]
  
  tags = {
    Name = "MyNetworkInterface_01"
  }
  
  
}
	
resource "aws_instance" "jenkins_server" {
  ami           = var.my_jenkins_ami
  instance_type = var.my_jenkins_instance_type
  key_name = var.my_aws_key_name
  
  tags = {
    Name = "jenkins_server"
  }
  
  network_interface {
    network_interface_id = "${aws_network_interface.MyNetworkInterface_01.id}"
    device_index = 0
  }
  
  # ssh into the ec2 instance 
  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file(var.private_key_path)
    host        = aws_instance.jenkins_server.public_ip
  }
  
  provisioner "file" {
    source      = "jenkins-compose.yaml"
    destination = "/tmp/jenkins-compose.yaml"
  }
  
  user_data = file("install-Docker-Jenkins.sh")    

  
}

output "jenkins_server_dns" {
  value = aws_instance.jenkins_server.public_dns
}


