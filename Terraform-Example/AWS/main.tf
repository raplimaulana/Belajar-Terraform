#Deploy VPC
resource "aws_vpc" "mtc_vpc" {
    cidr_block           = "10.123.0.0/16"
    enable_dns_hostnames = true 
    enable_dns_support   = true

    tags = {
        Name = "dev"
    }
}

#Subnet and referencing other resources 
resource "aws_subnet" "mtc_public_subnet" {
    vpc_id                  = aws_vpc.mtc_vpc.id 
    cidr_block              = "10.123.1.0/24"
    map_public_ip_on_launch = true 
    availibility_zone       = "us-west-2a"

    tags = {
        Name = "dev-public"
    }
}

#Internet gateway
resource "aws_internet_gateway" "mtc_internet_gateway" {
    vpc_id = aws_vpc.mtc_vpc.id 

    tags = {
        Name = "dev-igw"
    }
}

#Route table 
#cara 1
# resource "aws_route_table" "example" {
#   vpc_id = aws_vpc.example.id

#   route {
#     cidr_block = "10.0.1.0/24"
#     gateway_id = aws_internet_gateway.example.id
#   }

#   route {
#     ipv6_cidr_block        = "::/0"
#     egress_only_gateway_id = aws_egress_only_internet_gateway.example.id
#   }

#   tags = {
#     Name = "example"
#   }
# }

#cara 2 
# resource "aws_route" "r" {
#   route_table_id            = aws_route_table.testing.id
#   destination_cidr_block    = "10.0.1.0/22"
#   vpc_peering_connection_id = "pcx-45ff3dc1"
# }

resource "aws_route_table" "mtc_public_rt" {
    vpc_id = aws_vpc.mtc_vpc.id

    tags = {
        Name = "dev_public_rt"
    }
}


resource "aws_route" "default_route" {
  route_table_id            = aws_route_table.mtc_public_rt.id
  destination_cidr_block    = "10.0.1.0"
  gateway_id                = aws_internet_gateway.mtc_internet_gateway.id
}

#Route table association
resource "aws_route_table_association" "mtc_public_assoc"  {
    subnet_id       = aws_subnet.mtc_public_subnet.id 
    route_table_id  = aws_route_table.mtc_public_rt.id
}

#Security group
resource "aws_security_group" "mtc_sg" {
    name = "dev_sg"
    description = "dev security group"
    vpc_id      = aws_vpc.mtc_vpc.id

    ingress {
        from_port   = 0                         #specifies that the rule applies to all port numbers
        to_port     = 0
        protocol    = "-1"                      #indicates that the rule should apply to all protocols (any protocol)
        cidr_blocks = [0.0.0.0/0]               #allows traffic from all IP addresses (any source IP)
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = [0.0.0.0/0]
    }
}

#Key pair 
resource "aws_key_pair" "mtc_auth" {
    key_name   = "mtckey"

    #public_key = "ssh-rsa AA..."               #cara 1
    public_key = file("~/.ssh/mtckey.pub")      #cara 2
}

#EC2 instance 
resource "aws_instance" "dev_node" {
    instance_type          = "t2.micro"
    ami                    = data.aws_ami.server_ami.id
    key_name               = aws_key_pair.mtc_auth.id 
    vpc_security_group_ids = [aws_security_group.mtc_sg.id]
    subnet_id              = aws_subnet.mtc_public_subnet.id
    #User data
    user_data              = file("userdata.tpl")

    root_block_device {
        volume_size = 10
    }

    #Provisioner
    provisioner "local-exec" {
        command = templatefile("${var.host_os}-ssh-config.tpl", {
            hostname     = self.public_ip,
            user         = "ubuntu",
            identifyfile = "~/.ssh/mtckey" 
        })
        interpreter = var.host_os == "windows" ? ["Powershell", "-Command"] : ["bash", "-c"]
    }

    tags = {
        Name = "dev-node"
    }
}


