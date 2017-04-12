#!/bin/bash


# Install Docker and some other packages

cat >/etc/yum.repos.d/docker.repo <<-EOF
[dockerrepo]
name=Docker Repository
baseurl=https://yum.dockerproject.org/repo/main/centos/7
enabled=1
gpgcheck=1
gpgkey=https://yum.dockerproject.org/gpg
EOF

yum -y install docker-engine

# Enable the Docker service

systemctl enable docker.service
systemctl start docker.service


yum -y install html2text

# Already install some Docker images

sudo docker pull centos
sudo docker pull nginx
sudo docker pull ubuntu

add an entry to the file ~/.bashrc

echo "sudo -i; exit" >> /home/vagrant/.bashrc
