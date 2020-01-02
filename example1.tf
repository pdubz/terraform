provider "aws" {
	profile 	= "default"
	region		= "us-east-2"
}

resource "aws_key_pair" "centos" {
	key_name	= "centos"
	public_key	= "${file("centos.pub")}"
}
resource "aws_instance" "example" {
	ami				= "ami-d9e3c4bc"
	instance_type	= "t2.micro"
	key_name		= "centos"
	user_data		= "${file("userdata.sh")}"
}
