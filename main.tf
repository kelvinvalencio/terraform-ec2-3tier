terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  shared_config_files      = ["~/.aws/conf"]
  shared_credentials_files = ["~/.aws/credentials"]
  profile                  = var.aws_profile
  region                   = var.region
}

resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = "${file("~/.ssh/deployer.pub")}"
}

resource "aws_vpc" "vpc" {
  cidr_block       = var.VPC_CIDR
  instance_tenancy = "default"

  tags = {
    Name = "vpc-${var.CUSTOMER_NAME}"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "igw-${var.CUSTOMER_NAME}"
  }
}

resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.vpc.id
  # cidr_block        = cidrsubnet(var.VPC_CIDR, var.subnet_bits, 0) 
  cidr_block        = var.VPC_CIDR
  map_public_ip_on_launch = true

  tags = {
    Name = "subnet-${var.CUSTOMER_NAME}"
  }
}

resource "aws_route_table_association" "public_rt_to_private_subnet" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.vpc.id

  

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public-rt-${var.CUSTOMER_NAME}"
  }
}

resource "aws_security_group" "sg_app" {
  vpc_id      = aws_vpc.vpc.id
  description = "Application"
  tags = { Name = "sg-app-${var.CUSTOMER_NAME}" }
}

resource "aws_security_group" "sg_engine" {
  vpc_id      = aws_vpc.vpc.id
  description = "Engine"
  tags = { Name = "sg-engine-${var.CUSTOMER_NAME}" }
}

resource "aws_security_group" "sg_db" {
  vpc_id      = aws_vpc.vpc.id
  description = "Database"
  tags = { Name = "sg-db-${var.CUSTOMER_NAME}" }
}

resource "aws_security_group" "sg_ml" {
  vpc_id      = aws_vpc.vpc.id
  description = "Machine Learning"
  tags = { Name = "sg-ml-${var.CUSTOMER_NAME}" }
}

resource "aws_security_group" "sg_db_staging" {
  vpc_id      = aws_vpc.vpc.id
  description = "Staging Database"
  tags = { Name = "sg-db_staging-${var.CUSTOMER_NAME}" }
}

# combine security groups into a map
locals {
  security_groups = {
    sg_app    = aws_security_group.sg_app
    sg_engine = aws_security_group.sg_engine
    sg_db     = aws_security_group.sg_db
    sg_ml     = aws_security_group.sg_ml
    sg_db_staging = aws_security_group.sg_db_staging
  }
}

resource "aws_security_group_rule" "allow_ssh_all" {
  for_each          = local.security_groups

  
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  security_group_id = local.security_groups[each.key].id
  cidr_blocks       = var.authenticated_networks
  description       = "SSH access from authenticated networks"
}

resource "aws_security_group_rule" "allow_app_to_db" {
  type              = "ingress"
  from_port         = 5432
  to_port           = 5432
  protocol          = "tcp"
  security_group_id = aws_security_group.sg_db.id
  source_security_group_id = aws_security_group.sg_app.id
  description       = "Allow app to db access"
}

resource "aws_security_group_rule" "allow_engine_to_db" {
  type              = "ingress"
  from_port         = 5432
  to_port           = 5432
  protocol          = "tcp"
  security_group_id = aws_security_group.sg_db.id
  source_security_group_id = aws_security_group.sg_engine.id
  description       = "Allow app to db access"
}

resource "aws_instance" "instance" {
  for_each        = var.instances


  key_name = aws_key_pair.deployer.key_name
  subnet_id       = aws_subnet.private_subnet.id
  private_ip      = each.value.private_ip
  vpc_security_group_ids = [local.security_groups[each.value.security_group].id]
  associate_public_ip_address = true  

  ami             = each.value.ami
  instance_type   = each.value.instance_type

  ebs_block_device {
    device_name          = "/dev/xvda"
    volume_size          = each.value.volume_size
    delete_on_termination = true
    volume_type         = "gp3"
    encrypted           = true
  }

  tags = {
    Name = each.value.instance_name
  }
}
