#我们还想让ssh access这个vpc，需要设置security group，允许port 22和port 8080可以access
resource "aws_security_group" "myapp-sg" {
  name   = "myapp-sg"
  vpc_id = var.vpc_id

  #for ssh
  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    #google搜我的ip/32,即只有我一个ip可以访问
    cidr_blocks = ["139.218.17.163/32"]
  }

  #for 外部网络连接，cidr_blocks=[0.0.0.0/0]是任何ip range，protocol=“-1”也是任意
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
    prefix_list_ids = []
  }
}

#launch a EC2 instance
#在AWS中需要Amazon Machine Image，但因为这个image会不断更新版本，所以不能写死一个ID在ami上
resource "aws_instance" "myapp-server" {
  # ami = "ami-0b655e6d4a96567d4"
  ami           = data.aws_ami.latest-amazon-linux-image.id
  instance_type = var.instance_type
  #连接创建的subnet 和 security grop，这里subnet已经被抽到另外一个module，subnet的id需要那个module export出来
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [aws_security_group.myapp-sg.id]

  availability_zone = var.availability_zone

  associate_public_ip_address = true
  # key_name = "aws-key"
  key_name = "terraform-project-1-module_key"

  #现在想要server里运行docker，写一些script
  #通过 systemctl 命令，系统管理员可以查看系统服务的状态、启动或停止服务、重启服务以及管理系统的各种单元（units）
  #sudo systemctl start docker 中的systemctl在这个ami中没有，导致docker没运行，所以改成sudo service docker start
  # user_data = <<EOF
  #               #!/bin/bash
  #               sudo yum update -y && sudo yum install -y docker
  #               sudo service docker start
  #               sudo usermod -aG docker ec2-user
  #               docker run -p 8080:80 nginx
  #               EOF
  user_data = file("entry-script.sh")
  tags = {
    Name = "${var.env_prefix}-server"
  }
}

#可以用data去query最新的amazon machine image
data "aws_ami" "latest-amazon-linux-image" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name = "name"
    #这个名字在aws搜ami catalog，选择community amis
    values = ["amzn2-ami-kernel-5.10-hvm-*-x86_64-gp2"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

#ssh连接的时候，我不想手动创建key pair
resource "aws_key_pair" "ssh-key" {
  key_name = "terraform-project-1-module_key"
  #读取文件，存的是路径
  public_key = file(var.my_public_key_location)
}
