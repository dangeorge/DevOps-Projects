resource "aws_vpc" "webvpc" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "webvpc"
  }
}

resource "aws_subnet" "websubnet1" {
  vpc_id                  = aws_vpc.webvpc.id
  cidr_block              = "10.0.0.0/24"
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "websubnet1"
  }
}

resource "aws_subnet" "websubnet2" {
  vpc_id                  = aws_vpc.webvpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-south-1b"
  map_public_ip_on_launch = true
  tags = {
    Name = "websubnet2"
  }
}

resource "aws_internet_gateway" "webigw" {
  vpc_id = aws_vpc.webvpc.id
  tags = {
    Name = "webigw"
  }
}

resource "aws_route_table" "webrt" {
  vpc_id = aws_vpc.webvpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.webigw.id
  }
  tags = {
    Name = "webrt"
  }
}

resource "aws_route_table_association" "webrta1" {
  subnet_id      = aws_subnet.websubnet1.id
  route_table_id = aws_route_table.webrt.id
}

resource "aws_route_table_association" "webrta2" {
  subnet_id      = aws_subnet.websubnet2.id
  route_table_id = aws_route_table.webrt.id
}

resource "aws_security_group" "websg" {
  name   = "websg"
  vpc_id = aws_vpc.webvpc.id

  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "websg"
  }
}

resource "aws_instance" "webserver1" {
  ami                    = "ami-03f4878755434977f"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.websg.id]
  subnet_id              = aws_subnet.websubnet1.id
  user_data              = base64encode(file("userdata1.sh"))
  tags = {
    Name = "webserver1"
  }
}

resource "aws_instance" "webserver2" {
  ami                    = "ami-03f4878755434977f"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.websg.id]
  subnet_id              = aws_subnet.websubnet2.id
  user_data              = base64encode(file("userdata2.sh"))
  tags = {
    Name = "webserver2"
  }
}

#Create Application Load Balancer
resource "aws_lb" "webalb" {
  name               = "webalb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.websg.id]
  subnets            = [aws_subnet.websubnet1.id, aws_subnet.websubnet2.id]

  tags = {
    Name = "webalb"
  }
}

resource "aws_lb_target_group" "webtg" {
  name     = "webtg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.webvpc.id

  health_check {
    path = "/"
    port = "traffic-port"
  }
}

resource "aws_lb_target_group_attachment" "webtgattach1" {
  target_group_arn = aws_lb_target_group.webtg.arn
  target_id        = aws_instance.webserver1.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "webtgattach2" {
  target_group_arn = aws_lb_target_group.webtg.arn
  target_id        = aws_instance.webserver2.id
  port             = 80
}

resource "aws_lb_listener" "weblistener" {
  load_balancer_arn = aws_lb.webalb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.webtg.arn
    type             = "forward"
  }
}