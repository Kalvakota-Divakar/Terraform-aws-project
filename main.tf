# create vpc
resource "aws_vpc" "myvpc" {
  cidr_block = var.CIDR
}

# create two subnets in different availability zones
resource "aws_subnet" "my_subnet1" {
  vpc_id            = aws_vpc.myvpc.id
  cidr_block        = var.subnet1_cidr
  availability_zone = var.availability_zone1
  map_public_ip_on_launch = true
}

resource "aws_subnet" "my_subnet2" {
  vpc_id            = aws_vpc.myvpc.id
  cidr_block        = var.subnet2_cidr
  availability_zone = var.availability_zone2
  map_public_ip_on_launch = true
}

# create internet gateway
resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.myvpc.id
}

# create route table and add a route to the internet gateway
resource "aws_route_table" "RT" {
    vpc_id = aws_vpc.myvpc.id
    route {
        cidr_block = "0.0.0.0/0" # 0.0.0.0/0 means this allow all traffic to the internet
        gateway_id = aws_internet_gateway.igw.id
    }
}

# associate the route table with the subnets
resource "aws_route_table_association" "RTa1" {
    subnet_id      = aws_subnet.my_subnet1.id
    route_table_id = aws_route_table.RT.id
}

resource "aws_route_table_association" "RTa2" {
    subnet_id = aws_subnet.my_subnet2.id
    route_table_id = aws_route_table.RT.id
}

# create security group
resource "aws_security_group" "sg" {
    name = "my_sg"
    vpc_id = aws_vpc.myvpc.id

    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "my_sg"
    }
}

# create s3 bucket
resource "aws_s3_bucket" "mybucket" {
  bucket = "my-project-yuvi"
}

# create two ec2 instances in different subnets and attach them to the security group
resource "aws_instance" "my_instance1" {
    ami = var.ami_id
    instance_type = var.instance_type
    vpc_security_group_ids = [aws_security_group.sg.id]
    subnet_id = aws_subnet.my_subnet1.id
    user_data = base64encode(file("userdata.sh"))
}

resource "aws_instance" "my_instance2" {
    ami = var.ami_id
    instance_type = var.instance_type
    vpc_security_group_ids = [aws_security_group.sg.id]
    subnet_id = aws_subnet.my_subnet2.id
    user_data = base64encode(file("userdata1.sh"))
}

#create alb
resource "aws_lb" "myalb" {
  name               = "myalb"
  internal           = false
  load_balancer_type = "application"

  security_groups = [aws_security_group.sg.id]
  subnets         = [aws_subnet.my_subnet1.id, aws_subnet.my_subnet2.id]

  tags = {
    Name = "web"
  }
}

resource "aws_lb_target_group" "tg" {
  name     = "myTG"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.myvpc.id

  health_check {
    path = "/"
    port = "traffic-port"
  }
}

resource "aws_lb_target_group_attachment" "attach1" {
  target_group_arn = aws_lb_target_group.tg.arn
  target_id        = aws_instance.my_instance1.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "attach2" {
  target_group_arn = aws_lb_target_group.tg.arn
  target_id        = aws_instance.my_instance2.id
  port             = 80
}

resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.myalb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.tg.arn
    type             = "forward"
  }
}

output "loadbalancerdns" {
  value = aws_lb.myalb.dns_name
}