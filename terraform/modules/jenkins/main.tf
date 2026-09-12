# AMAZON LINUX 2023 AMI

data "aws_ssm_parameter" "al2023_ami" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}


# JENKINS EC2 INSTANCE

resource "aws_instance" "jenkins"{
    ami = data.aws_ssm_parameter.al2023_ami.value

    instance_type = var.instance_type
    subnet_id = var.public_subnet_id

    vpc_security_group_ids = [
        var.jenkins_security_group_id
    ]
    
      iam_instance_profile = var.jenkins_instance_profile_name
    associate_public_ip_address = true

    user_data = <<-EOF
    #!/bin/bash

    set -e 

    # update system

    dnf update -y

    # install java

    dnf install -y java-21-amazon-corretto

    # add jenkins repository
    wget -O /etc/yum.repos.d/jenkins.repo \
      https://pkg.jenkins.io/redhat-stable/jenkins.repo

    rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key


    # install jenkins

    dnf install -y jenkins

    # install docker

    dnf install -y docker

    systemctl enable docker
    systemctl start docker


    # add jenkins user to docker group
    usermod -aG docker jenkins

    # start jenkins

    systemctl enable jenkins
    systemctl start jenkins

    EOF

    tags = {
        Name = "${var.project_name}-jenkins"
        Project = var.project_name
        Tier = "cicd"
        Environment = "dev"
    }
}