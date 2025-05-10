provider "aws" {
    region = "us-east-1"
}

resource "aws_key_pair" "default"{
    key_name = "react-key"
    public_key = file("~/.ssh/id_rsa.pub")
}

resource "aws_security_group" "sg"{
    name = "allow-http-ssh"
    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        ipv6_cidr_blocks = ["::/0"]
    }

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        ipv6_cidr_blocks = ["::/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
        ipv6_cidr_blocks = ["::/0"]
    }


}

resource "aws_instance" "react_app"{
    ami = "ami-0f9de6e2d2f067fca"
    instance_type = "t2.micro"
    key_name = aws_key_pair.default.key_name
    vpc_security_group_ids = [aws_security_group.sg.id]
    associate_public_ip_address = true

    user_data = <<-EOF
    #!/bin/bash
    set -xe

    apt-get update -y
    apt-get upgrade -y
    apt-get install -y apt-transport-https ca-certificates curl software-properties-common gnupg lsb-release

    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list

    apt-get update -y
    apt-get install -y docker-ce docker-ce-cli containerd.io

    systemctl enable docker
    systemctl start docker

    usermod -aG docker ubuntu

    docker pull unetoaraujo/react-app

    docker run -d -p 80:80 --name react-app --restart unless-stopped unetoaraujo/react-app

    EOF

    tags = {
        Name = "ReactApp"
    }

}