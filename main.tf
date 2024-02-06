provider "aws" {
  region = "eu-west-2"
}

resource "aws_instance" "this" {
  ami                    = "ami-0ff1c68c6e837b183"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.this.id]

  user_data = <<-EOF
              #!/bin/bash
              echo "Hello World" > index.html
              nohup busybox httpd -f -p ${var.server_port} &
              EOF

  user_data_replace_on_change = true

  tags = {
    Name    = "terraform-example"
    Service = "tf-up-running"
  }
}

resource "aws_security_group" "this" {
  name = "terraform-example-instance"

  ingress {
    from_port   = var.server_port
    to_port     = var.server_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

variable "server_port" {
  description = "The port the server will use for HTTP requests"
  type        = number
  default     = 8080
}

output "public_ip" {
  value       = aws_instance.this.public_ip
  description = "The public IP of the web server"
}