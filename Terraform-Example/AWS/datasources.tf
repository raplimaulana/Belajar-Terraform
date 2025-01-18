#AMI datasource
#Chose AMI via create EC2 instance 
#Copy owner ID after create EC2 instance (EC2 > Images > AMI > Owner)
data "aws_ami" "server_ami" {
    most_recent = true 
    owners     = ["099720109477"]

    filter {
        name   = "name"
        values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
    } 
}