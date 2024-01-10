vpc_cidr_block = "10.0.0.0/16"
env_prefix     = "dev"
#如VPC 的 CIDR 是 10.0.0.0/16，这意味着你的 VPC 覆盖了 10.0.0.0 到 10.0.255.255 的范围。
#但是，对于子网，你可以选择一个子集范围，例如 10.0.10.1/24 
subnet_cidr_block      = "10.0.10.0/24"
availability_zone      = "ap-southeast-2a"
instance_type          = "t2.micro"
my_public_key_location = "~/.ssh/id_rsa.pub"
