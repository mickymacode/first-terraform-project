#!/bin/bash
  sudo yum update -y && sudo yum install -y docker
  sudo service docker start
  sudo usermod -aG docker ec2-user
  # 添加延迟，确保 Docker 服务完全启动
  sleep 10
  docker run -p 8080:80 nginx