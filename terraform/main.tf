provider "aws" {
  region = "eu-north-1"
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners = ["099720109477"] # Canonical
}

data "aws_ami" "centos8" {
  most_recent = true
  owners = ["679593333241"]
#  name_regex = "^CentOS.Linux.8.*x86_64.*"
  filter {
    name = "name"
    values = ["CentOS 8*"]
  }
}


locals {
  test1_instance_type_map = {
    stage = "t3.micro"
    prod = "t3.large"
  }

  test1_count_map = {
    stage = 1
    prod = 2
  }

  ami_map = {
    "ubuntu" = data.aws_ami.ubuntu.id
    "centos8" = data.aws_ami.centos8.id
  }
}

variable "params" {
  description = "just little map"
  type = map
  default = {
    type1 = {
      ami = "ubuntu",
      volume_size = 10
    },
    type2 = {
      ami = "centos8",
      volume_size = 15
    }
  }
}

resource "aws_key_pair" "aws_test" {
  key_name   = "aws_test-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCw7sNJ4cQunfNcUBsouM5L8UXerjqgGlsMjgCek2PMeLyz9bYBGoVvL9aR1AuAKIc/+E2RZl9DmK4cpyAXIfbUfwX5m+lYndZ+Z3DaRC6Y3IXdpQZ5Wc9pKMcGNW1I3+HhDyVJ05e07/OnZkPNRRRgk1jv7/ujTxC7Z9ubRPEoFXnaA72pLiv7Q6VDzapT0IqTNCiu7yGb0J9xHrVaVzOIdx1lAQJdpmZ7FW0hBu5AlryqtD8xTHtw+dnnO+Lo2fT1BWFQEHDr+COQN12O1xzqcORadLegl4B5KnBGOivQtald3fJTd2WYYNhgb8w7pjh3b3iuY3IvLpU0QOtLnzKt example"
}

resource "aws_vpc" "test_vpc" {
  cidr_block = "192.168.0.0/16"
}

resource "aws_subnet" "test_vpc_net11" {
  vpc_id            = aws_vpc.test_vpc.id
  cidr_block        = "192.168.11.0/24"
  availability_zone = "eu-north-1"
}

resource "aws_network_interface" "test_vpc_4test1" {
  subnet_id   = aws_subnet.test_vpc_net11.id
  private_ips = ["192.168.11.1"]
}


resource "aws_instance" "test1" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = local.test1_instance_type_map[terraform.workspace]
  count = local.test1_count_map[terraform.workspace]

  tags = {
    Name = "neto-test.1"
  }

  lifecycle {
    create_before_destroy = true
  }

  network_interface {
    network_interface_id = aws_network_interface.test_vpc_4test1.id
    device_index         = 0
  }

  associate_public_ip_address = true
  cpu_core_count = 1
  cpu_threads_per_core = 1
  credit_specification {
    cpu_credits = "standard"
    }
  disable_api_termination = true	# can not be deleted via API
  ebs_optimized = true			# dedicated bandwidth to Amazon EBS I/O
  hibernation = true
  instance_initiated_shutdown_behavior = "stop"
  ipv6_address_count = 0
  key_name = "aws_test-key"
  monitoring = true
  source_dest_check = true
  root_block_device {
    volume_type = "standard"		# standard, gp2, gp3, io1, io2, sc1, st1
    volume_size = 10				# GiB
    delete_on_termination = true
    encrypted = false
    tags = {
      Description = "just root disk"
    }
  }
}

resource "aws_instance" "test_pool" {
  for_each = var.params

  tags = {
    Name = "test_pool-${each.key}-${each.value.ami}"
  }
  ami = "${lookup(local.ami_map, each.value.ami)}"
  instance_type = local.test1_instance_type_map[terraform.workspace]
  root_block_device {
    volume_type = "standard"
    volume_size = each.value.volume_size
    delete_on_termination = true
    encrypted = false
  }
}
