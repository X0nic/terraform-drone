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
  ami = "ami-018c9568"
  instance_type = "t1.micro"

  connection {
    user = "ubuntu"
    key_file = "${var.key_path}"
  }
  key_name = "${var.key_name}"

  # Our Security group to allow HTTP and SSH access
  security_groups = ["${aws_security_group.drone.name}"]

  provisioner "remote-exec" {
    inline = [
        "sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 36A1D7869245C8950F966E92D8576A8BA88D21E9",
        "sudo sh -c \"echo deb https://get.docker.com/ubuntu docker main > /etc/apt/sources.list.d/docker.list\"",
        "sudo apt-get -y update",
        "sudo apt-get -y install libsqlite3-dev lxc-docker",
        "wget downloads.drone.io/master/drone.deb",
        "sudo dpkg --install drone.deb"
    ]
  }
}
