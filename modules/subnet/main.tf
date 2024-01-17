#创建subnet
resource "aws_subnet" "myapp-subnet-1" {
  #连接上vpc
  vpc_id            = var.vpc_id
  cidr_block        = var.subnet_cidr_block
  availability_zone = var.availability_zone
  tags = {
    Name = "${var.env_prefix}-subnet-1"
  }
}

#创建route table，如果不用default的
#route table只有local，用于vpc内部沟通，但是还需要一个entry point用于与外部broweser access，所以需要设置这个gateway
resource "aws_route_table" "myapp-rtb" {
  #连接上vpc
  vpc_id = var.vpc_id

  route {
    #设置cidr_block为任意ip
    cidr_block = "0.0.0.0/0"
    #需要gateway的id,下面创建的
    gateway_id = aws_internet_gateway.myapp-igw.id
  }
  tags = {
    Name = "${var.env_prefix}-rtb"
  }
}

resource "aws_internet_gateway" "myapp-igw" {
  #连接vpc
  vpc_id = var.vpc_id
  tags = {
    Name : "${var.env_prefix}-igw"
  }
}

#还需要设置Subnet Associate，让subnet与route table连接起来, 因为没用default route table，所以需要连接
resource "aws_route_table_association" "a-rtb-subnet" {
  subnet_id      = aws_subnet.myapp-subnet-1.id
  route_table_id = aws_route_table.myapp-rtb.id
}

#也可以用default route table，这样是不用connect subnet和 route table
# resource "aws_default_route_table" "main-rtb" {
#   #default route table是vpc的default route tabel
#   default_route_table_id = aws_vpc.myapp-vpc.default_route_table_id

#   route {
#     cidr_block = "0.0.0.0/0"
#     gateway_id = aws_internet_gateway.myapp-igw.id
#   }
#   tags = {
#     Name: "${var.env_prefix}-main-rtb"
#   }
# }
