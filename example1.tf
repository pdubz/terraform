provider "aws" {
	profile 	= "default"
	region		= "us-east-2"
}

resource "aws_instance" "example" {
	ami				= "ami-d9e3c4bc"
	instance_type	= "t2.micro"
}
