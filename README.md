# terraform-jenkins
This repo store terraform project that start jenkins boxes

Prerequisites
-------------

1) Create an aws account. 
2) Create a key pairs on AWS in the region where you will deploy this project
3) Terraform Installed locally


terraform init

terraform validate

terraform apply


aws_instance.jenkins_server: Still creating... [20s elapsed]
aws_instance.jenkins_server: Still creating... [30s elapsed]
aws_instance.jenkins_server: Provisioning with 'file'...
aws_instance.jenkins_server: Creation complete after 36s [id=i-00ab9d34369f4de45]

Apply complete! Resources: 1 added, 1 changed, 0 destroyed.

Outputs:

jenkins_server_dns = "ec2-35-173-202-222.compute-1.amazonaws.com"



sudo cat /var/log/cloud-init-output.log



************************* INSTALLATION SCRIPTS - END **************
************************* STARGING JENKINS - BEGIN **************
Creating network "jenkins-compose_default" with the default driver
Pulling jenkins (jenkins/jenkins:lts)...
lts: Pulling from jenkins/jenkins
Digest: sha256:0944e18261a6547e89b700cec432949281a7419a6165a3906e78c97efde3bc86
Status: Downloaded newer image for jenkins/jenkins:lts
Creating jenkins ... done
************************* STARGING JENKINS - END **************


sudo docker logs jenkins

Jenkins initial setup is required. An admin user has been created and a password generated.
Please use the following password to proceed to installation:

LARGEPASSSWORDNUMBERHERE

This may also be found at: /var/jenkins_home/secrets/initialAdminPassword

*************************************************************


http://ec2-35-173-202-222.compute-1.amazonaws.com:8080/
