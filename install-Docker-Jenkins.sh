#!/bin/bash
#set -ex
sudo echo '************************* INSTALLATION SCRIPTS - BEGIN **************'
sudo yum update -y
sudo amazon-linux-extras install docker -y
sudo usermod -aG docker ec2-user
sudo service docker start

sudo curl -L https://github.com/docker/compose/releases/download/1.25.4/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

sudo mkdir /data
sudo mkdir -p /opt/jenkins-compose
sudo mv /tmp/jenkins-compose.yaml /opt/jenkins-compose/
sudo chmod 755 /opt/jenkins-compose/jenkins-compose.yaml

#sudo ls -lh /opt > /tmp/listDir.txt


#sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
#sudo service docker restart

sudo echo '************************* INSTALLATION SCRIPTS - END **************'

sudo echo '************************* STARGING JENKINS - BEGIN **************'
cd /opt/jenkins-compose/
docker-compose -f jenkins-compose.yaml up -d
docker logs jenkins
sudo echo '************************* STARGING JENKINS - END **************'