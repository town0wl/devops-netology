provider "aws" {
  region = "eu-north-1"
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners = ["099720109477"] # Canonical
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
  availability_zone = "eu-north-1c"
}

resource "aws_network_interface" "test_vpc_4test1" {
  subnet_id   = aws_subnet.test_vpc_net11.id
  private_ips = ["192.168.11.111"]
}

module "test1" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "3.3.0"
  
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"
  tags = {
    Label = "neto-test.1"
  }
#  associate_public_ip_address = true		# This will not work because of ec2_instance module restrictions
  hibernation = true
  cpu_core_count = 1
  cpu_threads_per_core = 1
  cpu_credits = "standard"
  disable_api_termination = true
  ebs_optimized = true
  instance_initiated_shutdown_behavior = "stop"
  ipv6_address_count = 0			# Not working for some reason
  key_name = "aws_test-key"
  monitoring = true
  source_dest_check = true
  
  network_interface = [
    {
      device_index          = 0
      network_interface_id  = aws_network_interface.test_vpc_4test1.id
    }
  ]

  enable_volume_tags = false
  root_block_device = [
    {
      encrypted   = false
      volume_type = "standard"
      volume_size = 10
      delete_on_termination = true
      tags = {
        Description = "just root disk"
      }
    },
  ]

}
