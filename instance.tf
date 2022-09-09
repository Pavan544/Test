provider "aws"{
 region="ap-south-1"
}

resource "aws_instance" "web"{
ami ="ami-06489866022e12a14"
instance_type="t2.micro"
}
tags={
Name = Web-server"
}
