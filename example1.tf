provider "aws" {
	profile 	= "default"
	region		= "us-east-2"
}

resource "tls_private_key" "centos-test-key" {
	algorithm	= "RSA"
	rsa_bits	= 4096
}

resource "aws_key_pair" "centos" {
	key_name	= "centos-test-key"
	public_key	= tls_private_key.centos-test-key.public_key_openssh
}

resource "aws_instance" "centos-test" {
	ami				= "ami-0f2b4fc905b0bd1f1"
	instance_type	= "t2.micro"
	key_name		= aws_key_pair.centos.key_name
	user_data		= file("userdata.sh")
}

resource "local_file" "centos-test-key-pem" {
	content		= tls_private_key.centos-test-key.private_key_pem
	filename	= "${aws_key_pair.centos.key_name}.pem"
}

output "public-dns" {
	value = aws_instance.centos-test.public_dns
}