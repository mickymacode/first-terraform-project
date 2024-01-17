provider "aws" {
  region = "ap-southeast-2"
}

#创建vpc
resource "aws_vpc" "myapp-vpc" {
  # cidr_block = "10.0.10.0/24" 
  #提取成variable
  cidr_block = var.vpc_cidr_block
  tags = {
    Name = "${var.env_prefix}-vpc"
  }
}

#把subnet，route table 和 internet gateway挪到subnet module里，其中Subnet Associate也挪走
module "myapp-subnet" {
  source            = "./modules/subnet"
  vpc_id            = aws_vpc.myapp-vpc.id
  subnet_cidr_block = var.subnet_cidr_block
  availability_zone = var.availability_zone
  env_prefix        = var.env_prefix
}

module "myapp-webserver" {
  source            = "./modules/webserver"
  vpc_id            = aws_vpc.myapp-vpc.id
  instance_type     = var.instance_type
  availability_zone = var.availability_zone
  #需要subnet id，subnet已经output了
  subnet_id              = module.myapp-subnet.subnet.id
  my_public_key_location = var.my_public_key_location
  env_prefix             = var.env_prefix
}


