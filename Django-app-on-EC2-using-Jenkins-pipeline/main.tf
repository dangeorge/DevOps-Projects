
provider "aws" {
  region = "ap-south-1"
}

resource "aws_instance" "Jenkins-server" {
    ami = "ami-03f4878755434977f"
    instance_type = "t2.micro"
    key_name = "jenkins-key"
    vpc_security_group_ids = [aws_security_group.Myserversg.id]
}

resource "aws_key_pair" "jenkins-key" {
    key_name = "jenkins-key"
    public_key = file("~/.ssh/id_rsa.pub")  
}

resource "aws_security_group" "Myserversg" {
    name = "Myserversg"

    ingress {
        description = "Allow SSH"
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        description = "Allow HTTP"
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        description = "Allow port 8080"
        from_port = 8080
        to_port = 8080
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    
    ingress {
        description = "Allow port 8000"
        from_port = 8000
        to_port = 8000
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "local_file" "inventory" {
    content = aws_instance.Jenkins-server.public_ip
    filename = "ansible/inventory.txt"  
}

output "server-details" {
    value = "Jenkins server is running at ${aws_instance.Jenkins-server.public_ip}"
}