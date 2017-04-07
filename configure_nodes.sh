#!/bin/bash

# Add entries from the Vagrant file to the /etc/hosts file

IFS=$'\n'
cat /vagrant/Vagrantfile |egrep "hostname|network" |awk 'NR%2{printf $0;next;}1' | tr -d "\"" | awk '{printf $7" "$3"\n"}' > /tmp/hosts
for LINE in `cat /tmp/hosts`
do
  IP=`echo $LINE |awk '{printf $1}'`
  FQDN=`echo $LINE |awk '{printf $2}'`
  SHORT=`echo $LINE |awk '{printf $2}'|cut -d "." -f 1`
  echo "${IP} ${SHORT} ${FQDN}" >> /etc/hosts
done
rm -f /tmp/hosts 




# install Docker engine

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
