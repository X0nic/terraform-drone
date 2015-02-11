provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region = "${var.region}"
}

# Our default security group to access
# the instances over SSH and HTTP
resource "aws_security_group" "drone" {
    name = "Drone"
    description = "Used in the terraform drone"

    # SSH access from anywhere
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    # HTTP access from anywhere
    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_elb" "drone" {
  name = "terraform-drone-elb"

  # The same availability zone as our instance
  availability_zones = ["${aws_instance.drone.availability_zone}"]

  listener {
    instance_port = 80
    instance_protocol = "http"
    lb_port = 80
    lb_protocol = "http"
  }

  # The instance is registered automatically
  instances = ["${aws_instance.drone.id}"]
}

resource "aws_instance" "drone" {
  ami = "ami-aa7ab6c2"
  instance_type = "t1.micro"

  connection {
    user = "ubuntu"
    key_file = "${var.key_path}"
  }
  key_name = "${var.key_name}"

  # Our Security group to allow HTTP and SSH access
  security_groups = ["${aws_security_group.drone.name}"]

  provisioner "local-exec" {
      command = "sudo apt-get -y update && sudo apt-get install libsqlite3-dev docker.io"
  }
}
