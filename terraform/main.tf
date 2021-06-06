provider "aws" {
    region = var.region
}
data "aws_availability_zones" "available" {
    state = "available"
}

data "aws_route_table" "finalLabRT" {
    vpc_id = aws_vpc.finalLabVPC.id
}

resource "tls_private_key" "mainKey" {
    algorithm = "RSA"
    rsa_bits = 4096  
}

output "tls_private_key" {
    value=tls_private_key.mainKey.private_key_pem
    sensitive = true
    }

resource "aws_key_pair" "ec2Key" {
    key_name = "ec2Key"
    public_key = tls_private_key.mainKey.public_key_openssh
}

resource "aws_vpc" "finalLabVPC" {
    cidr_block       = var.vpc_cidr_block
    instance_tenancy = "default"
    enable_dns_support = true
    tags = {
        Name = "finalLabVPC"
    }
}

resource "aws_subnet" "finaLabSubnet" {
  vpc_id                  = aws_vpc.finalLabVPC.id
  cidr_block              = var.subnet_cidr_block
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true
}

resource "aws_internet_gateway" "finalLabIGW" {
  vpc_id = aws_vpc.finalLabVPC.id

  tags = {
    Name = "finalLabIGW"
  }
}

resource "aws_route" "finalLabInternetRoute" {
  route_table_id         = data.aws_route_table.finalLabRT.id
  gateway_id             = aws_internet_gateway.finalLabIGW.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_security_group" "finalLabSG" {
    name        = "finalLabSG"
    description = "Allow ports for finalLab"
    vpc_id      = aws_vpc.finalLabVPC.id

    dynamic "ingress" {
        for_each = var.allow_ports
        content {
            from_port   = ingress.value
            to_port     = ingress.value
            protocol    = "tcp"
            cidr_blocks = ["0.0.0.0/0"]
        }
    }
    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_instance" "build_server" {
    ami = var.ami
    instance_type = var.instance_type
    vpc_security_group_ids = [aws_security_group.finalLabSG.id]
    subnet_id = aws_subnet.finaLabSubnet.id
    key_name = aws_key_pair.ec2Key.key_name
    user_data = file("build_user_data.sh")

    tags = {
        Name = "BuildServer"
  }
    connection {
        type = "ssh"
        host = aws_instance.build_server.public_ip
        user = "ubuntu"
        private_key = tls_private_key.mainKey.private_key_pem
        agent = false
    }   
    
    provisioner "file" {
        source = "../ansible/playbook.yml"
        destination = "/tmp/playbook.yml"
    }

    provisioner "file" {
        source = "../docker/Dockerfile"
        destination = "/tmp/Dockerfile"
    }
}

resource "aws_instance" "prod_server" {
    ami = var.ami
    instance_type = var.instance_type
    vpc_security_group_ids = [aws_security_group.finalLabSG.id]
    subnet_id = aws_subnet.finaLabSubnet.id
    user_data = file("prod_user_data.sh")
    key_name = aws_key_pair.ec2Key.key_name
    tags = {
        Name = "ProdServer"
  }
}
