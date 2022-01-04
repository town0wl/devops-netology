### ДЗ 7.4
1.
![alt text](https://github.com/town0wl/devops-netology/blob/main/images/terra_cloud_screen.jpg?raw=true)

2.
server.yaml
```
repos:
- id: /github\.com/town0wl/.*/
  branch: /main/
  apply_requirements: [approved, mergeable]
  workflow: custom
  allowed_overrides: [workflow]
  allowed_workflows: [custom]
  allow_custom_workflows: true
  delete_source_branch_on_merge: false

workflows:
  custom:
    plan:
      steps:
      - run: 'echo "plan started"'
      - init
      - plan:
          extra_args: ["-lock=false"]
    apply:
      steps:
      - run: 'echo "apply started"'
      - apply
```

atlantis.yaml
```
version: 3
projects:
- name: for_prod
  dir: terraform
  workspace: prod
  autoplan:
    when_modified: ["**.tf", "**.tfvars"]
    enabled: true
- name: for_stage
  dir: terraform
  workspace: stage
  autoplan:
    when_modified: ["**.tf", "**.tfvars"]
    enabled: true
```

3.
Модуль состоит из набора переменных, которые просто подставляет в описание создаваемого ресурса aws_instance. А также формирует ряд output для параметров создаваемого инстанса, но только для одного (первого), если их создается несколько. Модуль не вносит дополнительной функциональности по сравнению с обычным созданием ресурса aws_instance, даже если создается несколько ресурсов, поэтому его прямое использование не оправдано. Но может быть использован как заготовка для создания собственного кастомизированного модуля.\
https://github.com/town0wl/devops-netology/tree/main/terra_modules


### ДЗ 7.3
```
terraform workspace list
  default
* prod
  stage
```

```
terraform plan

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_instance.test1[0] will be created
  + resource "aws_instance" "test1" {
      + ami                                  = "ami-05213f30db96d0bde"
      + arn                                  = (known after apply)
      + associate_public_ip_address          = true
      + availability_zone                    = (known after apply)
      + cpu_core_count                       = 1
      + cpu_threads_per_core                 = 1
      + disable_api_termination              = true
      + ebs_optimized                        = true
      + get_password_data                    = false
      + hibernation                          = true
      + host_id                              = (known after apply)
      + id                                   = (known after apply)
      + instance_initiated_shutdown_behavior = "stop"
      + instance_state                       = (known after apply)
      + instance_type                        = "t3.large"
      + ipv6_address_count                   = 0
      + ipv6_addresses                       = (known after apply)
      + key_name                             = "aws_test-key"
      + monitoring                           = true
      + outpost_arn                          = (known after apply)
      + password_data                        = (known after apply)
      + placement_group                      = (known after apply)
      + placement_partition_number           = (known after apply)
      + primary_network_interface_id         = (known after apply)
      + private_dns                          = (known after apply)
      + private_ip                           = (known after apply)
      + public_dns                           = (known after apply)
      + public_ip                            = (known after apply)
      + secondary_private_ips                = (known after apply)
      + security_groups                      = (known after apply)
      + subnet_id                            = (known after apply)
      + tags                                 = {
          + "Name" = "neto-test.1"
        }
      + tags_all                             = {
          + "Name" = "neto-test.1"
        }
      + tenancy                              = (known after apply)
      + user_data                            = (known after apply)
      + user_data_base64                     = (known after apply)
      + vpc_security_group_ids               = (known after apply)

      + capacity_reservation_specification {
          + capacity_reservation_preference = (known after apply)

          + capacity_reservation_target {
              + capacity_reservation_id = (known after apply)
            }
        }

      + credit_specification {
          + cpu_credits = "standard"
        }

      + ebs_block_device {
          + delete_on_termination = (known after apply)
          + device_name           = (known after apply)
          + encrypted             = (known after apply)
          + iops                  = (known after apply)
          + kms_key_id            = (known after apply)
          + snapshot_id           = (known after apply)
          + tags                  = (known after apply)
          + throughput            = (known after apply)
          + volume_id             = (known after apply)
          + volume_size           = (known after apply)
          + volume_type           = (known after apply)
        }

      + enclave_options {
          + enabled = (known after apply)
        }

      + ephemeral_block_device {
          + device_name  = (known after apply)
          + no_device    = (known after apply)
          + virtual_name = (known after apply)
        }

      + metadata_options {
          + http_endpoint               = (known after apply)
          + http_put_response_hop_limit = (known after apply)
          + http_tokens                 = (known after apply)
        }

      + network_interface {
          + delete_on_termination = false
          + device_index          = 0
          + network_interface_id  = (known after apply)
        }

      + root_block_device {
          + delete_on_termination = true
          + device_name           = (known after apply)
          + encrypted             = false
          + iops                  = (known after apply)
          + kms_key_id            = (known after apply)
          + tags                  = {
              + "Description" = "just root disk"
            }
          + throughput            = (known after apply)
          + volume_id             = (known after apply)
          + volume_size           = 10
          + volume_type           = "standard"
        }
    }

  # aws_instance.test1[1] will be created
  + resource "aws_instance" "test1" {
      + ami                                  = "ami-05213f30db96d0bde"
      + arn                                  = (known after apply)
      + associate_public_ip_address          = true
      + availability_zone                    = (known after apply)
      + cpu_core_count                       = 1
      + cpu_threads_per_core                 = 1
      + disable_api_termination              = true
      + ebs_optimized                        = true
      + get_password_data                    = false
      + hibernation                          = true
      + host_id                              = (known after apply)
      + id                                   = (known after apply)
      + instance_initiated_shutdown_behavior = "stop"
      + instance_state                       = (known after apply)
      + instance_type                        = "t3.large"
      + ipv6_address_count                   = 0
      + ipv6_addresses                       = (known after apply)
      + key_name                             = "aws_test-key"
      + monitoring                           = true
      + outpost_arn                          = (known after apply)
      + password_data                        = (known after apply)
      + placement_group                      = (known after apply)
      + placement_partition_number           = (known after apply)
      + primary_network_interface_id         = (known after apply)
      + private_dns                          = (known after apply)
      + private_ip                           = (known after apply)
      + public_dns                           = (known after apply)
      + public_ip                            = (known after apply)
      + secondary_private_ips                = (known after apply)
      + security_groups                      = (known after apply)
      + subnet_id                            = (known after apply)
      + tags                                 = {
          + "Name" = "neto-test.1"
        }
      + tags_all                             = {
          + "Name" = "neto-test.1"
        }
      + tenancy                              = (known after apply)
      + user_data                            = (known after apply)
      + user_data_base64                     = (known after apply)
      + vpc_security_group_ids               = (known after apply)

      + capacity_reservation_specification {
          + capacity_reservation_preference = (known after apply)

          + capacity_reservation_target {
              + capacity_reservation_id = (known after apply)
            }
        }

      + credit_specification {
          + cpu_credits = "standard"
        }

      + ebs_block_device {
          + delete_on_termination = (known after apply)
          + device_name           = (known after apply)
          + encrypted             = (known after apply)
          + iops                  = (known after apply)
          + kms_key_id            = (known after apply)
          + snapshot_id           = (known after apply)
          + tags                  = (known after apply)
          + throughput            = (known after apply)
          + volume_id             = (known after apply)
          + volume_size           = (known after apply)
          + volume_type           = (known after apply)
        }

      + enclave_options {
          + enabled = (known after apply)
        }

      + ephemeral_block_device {
          + device_name  = (known after apply)
          + no_device    = (known after apply)
          + virtual_name = (known after apply)
        }

      + metadata_options {
          + http_endpoint               = (known after apply)
          + http_put_response_hop_limit = (known after apply)
          + http_tokens                 = (known after apply)
        }

      + network_interface {
          + delete_on_termination = false
          + device_index          = 0
          + network_interface_id  = (known after apply)
        }

      + root_block_device {
          + delete_on_termination = true
          + device_name           = (known after apply)
          + encrypted             = false
          + iops                  = (known after apply)
          + kms_key_id            = (known after apply)
          + tags                  = {
              + "Description" = "just root disk"
            }
          + throughput            = (known after apply)
          + volume_id             = (known after apply)
          + volume_size           = 10
          + volume_type           = "standard"
        }
    }

  # aws_instance.test_pool["type1"] will be created
  + resource "aws_instance" "test_pool" {
      + ami                                  = "ami-05213f30db96d0bde"
      + arn                                  = (known after apply)
      + associate_public_ip_address          = (known after apply)
      + availability_zone                    = (known after apply)
      + cpu_core_count                       = (known after apply)
      + cpu_threads_per_core                 = (known after apply)
      + disable_api_termination              = (known after apply)
      + ebs_optimized                        = (known after apply)
      + get_password_data                    = false
      + host_id                              = (known after apply)
      + id                                   = (known after apply)
      + instance_initiated_shutdown_behavior = (known after apply)
      + instance_state                       = (known after apply)
      + instance_type                        = "t3.large"
      + ipv6_address_count                   = (known after apply)
      + ipv6_addresses                       = (known after apply)
      + key_name                             = (known after apply)
      + monitoring                           = (known after apply)
      + outpost_arn                          = (known after apply)
      + password_data                        = (known after apply)
      + placement_group                      = (known after apply)
      + placement_partition_number           = (known after apply)
      + primary_network_interface_id         = (known after apply)
      + private_dns                          = (known after apply)
      + private_ip                           = (known after apply)
      + public_dns                           = (known after apply)
      + public_ip                            = (known after apply)
      + secondary_private_ips                = (known after apply)
      + security_groups                      = (known after apply)
      + source_dest_check                    = true
      + subnet_id                            = (known after apply)
      + tags                                 = {
          + "Name" = "test_pool-type1-ubuntu"
        }
      + tags_all                             = {
          + "Name" = "test_pool-type1-ubuntu"
        }
      + tenancy                              = (known after apply)
      + user_data                            = (known after apply)
      + user_data_base64                     = (known after apply)
      + vpc_security_group_ids               = (known after apply)

      + capacity_reservation_specification {
          + capacity_reservation_preference = (known after apply)

          + capacity_reservation_target {
              + capacity_reservation_id = (known after apply)
            }
        }

      + ebs_block_device {
          + delete_on_termination = (known after apply)
          + device_name           = (known after apply)
          + encrypted             = (known after apply)
          + iops                  = (known after apply)
          + kms_key_id            = (known after apply)
          + snapshot_id           = (known after apply)
          + tags                  = (known after apply)
          + throughput            = (known after apply)
          + volume_id             = (known after apply)
          + volume_size           = (known after apply)
          + volume_type           = (known after apply)
        }

      + enclave_options {
          + enabled = (known after apply)
        }

      + ephemeral_block_device {
          + device_name  = (known after apply)
          + no_device    = (known after apply)
          + virtual_name = (known after apply)
        }

      + metadata_options {
          + http_endpoint               = (known after apply)
          + http_put_response_hop_limit = (known after apply)
          + http_tokens                 = (known after apply)
        }

      + network_interface {
          + delete_on_termination = (known after apply)
          + device_index          = (known after apply)
          + network_interface_id  = (known after apply)
        }

      + root_block_device {
          + delete_on_termination = true
          + device_name           = (known after apply)
          + encrypted             = false
          + iops                  = (known after apply)
          + kms_key_id            = (known after apply)
          + throughput            = (known after apply)
          + volume_id             = (known after apply)
          + volume_size           = 10
          + volume_type           = "standard"
        }
    }

  # aws_instance.test_pool["type2"] will be created
  + resource "aws_instance" "test_pool" {
      + ami                                  = "ami-0d9f21605e64276df"
      + arn                                  = (known after apply)
      + associate_public_ip_address          = (known after apply)
      + availability_zone                    = (known after apply)
      + cpu_core_count                       = (known after apply)
      + cpu_threads_per_core                 = (known after apply)
      + disable_api_termination              = (known after apply)
      + ebs_optimized                        = (known after apply)
      + get_password_data                    = false
      + host_id                              = (known after apply)
      + id                                   = (known after apply)
      + instance_initiated_shutdown_behavior = (known after apply)
      + instance_state                       = (known after apply)
      + instance_type                        = "t3.large"
      + ipv6_address_count                   = (known after apply)
      + ipv6_addresses                       = (known after apply)
      + key_name                             = (known after apply)
      + monitoring                           = (known after apply)
      + outpost_arn                          = (known after apply)
      + password_data                        = (known after apply)
      + placement_group                      = (known after apply)
      + placement_partition_number           = (known after apply)
      + primary_network_interface_id         = (known after apply)
      + private_dns                          = (known after apply)
      + private_ip                           = (known after apply)
      + public_dns                           = (known after apply)
      + public_ip                            = (known after apply)
      + secondary_private_ips                = (known after apply)
      + security_groups                      = (known after apply)
      + source_dest_check                    = true
      + subnet_id                            = (known after apply)
      + tags                                 = {
          + "Name" = "test_pool-type2-centos8"
        }
      + tags_all                             = {
          + "Name" = "test_pool-type2-centos8"
        }
      + tenancy                              = (known after apply)
      + user_data                            = (known after apply)
      + user_data_base64                     = (known after apply)
      + vpc_security_group_ids               = (known after apply)

      + capacity_reservation_specification {
          + capacity_reservation_preference = (known after apply)

          + capacity_reservation_target {
              + capacity_reservation_id = (known after apply)
            }
        }

      + ebs_block_device {
          + delete_on_termination = (known after apply)
          + device_name           = (known after apply)
          + encrypted             = (known after apply)
          + iops                  = (known after apply)
          + kms_key_id            = (known after apply)
          + snapshot_id           = (known after apply)
          + tags                  = (known after apply)
          + throughput            = (known after apply)
          + volume_id             = (known after apply)
          + volume_size           = (known after apply)
          + volume_type           = (known after apply)
        }

      + enclave_options {
          + enabled = (known after apply)
        }

      + ephemeral_block_device {
          + device_name  = (known after apply)
          + no_device    = (known after apply)
          + virtual_name = (known after apply)
        }

      + metadata_options {
          + http_endpoint               = (known after apply)
          + http_put_response_hop_limit = (known after apply)
          + http_tokens                 = (known after apply)
        }

      + network_interface {
          + delete_on_termination = (known after apply)
          + device_index          = (known after apply)
          + network_interface_id  = (known after apply)
        }

      + root_block_device {
          + delete_on_termination = true
          + device_name           = (known after apply)
          + encrypted             = false
          + iops                  = (known after apply)
          + kms_key_id            = (known after apply)
          + throughput            = (known after apply)
          + volume_id             = (known after apply)
          + volume_size           = 15
          + volume_type           = "standard"
        }
    }

  # aws_key_pair.aws_test will be created
  + resource "aws_key_pair" "aws_test" {
      + arn             = (known after apply)
      + fingerprint     = (known after apply)
      + id              = (known after apply)
      + key_name        = "aws_test-key"
      + key_name_prefix = (known after apply)
      + key_pair_id     = (known after apply)
      + public_key      = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCw7sNJ4cQunfNcUBsouM5L8UXerjqgGlsMjgCek2PMeLyz9bYBGoVvL9aR1AuAKIc/+E2RZl9DmK4cpyAXIfbUfwX5m+lYndZ+Z3DaRC6Y3IXdpQZ5Wc9pKMcGNW1I3+HhDyVJ05e07/OnZkPNRRRgk1jv7/ujTxC7Z9ubRPEoFXnaA72pLiv7Q6VDzapT0IqTNCiu7yGb0J9xHrVaVzOIdx1lAQJdpmZ7FW0hBu5AlryqtD8xTHtw+dnnO+Lo2fT1BWFQEHDr+COQN12O1xzqcORadLegl4B5KnBGOivQtald3fJTd2WYYNhgb8w7pjh3b3iuY3IvLpU0QOtLnzKt example"
      + tags_all        = (known after apply)
    }

  # aws_network_interface.test_vpc_4test1 will be created
  + resource "aws_network_interface" "test_vpc_4test1" {
      + arn                = (known after apply)
      + id                 = (known after apply)
      + interface_type     = (known after apply)
      + ipv4_prefix_count  = (known after apply)
      + ipv4_prefixes      = (known after apply)
      + ipv6_address_count = (known after apply)
      + ipv6_addresses     = (known after apply)
      + ipv6_prefix_count  = (known after apply)
      + ipv6_prefixes      = (known after apply)
      + mac_address        = (known after apply)
      + outpost_arn        = (known after apply)
      + owner_id           = (known after apply)
      + private_dns_name   = (known after apply)
      + private_ip         = (known after apply)
      + private_ips        = [
          + "192.168.11.1",
        ]
      + private_ips_count  = (known after apply)
      + security_groups    = (known after apply)
      + source_dest_check  = true
      + subnet_id          = (known after apply)
      + tags_all           = (known after apply)

      + attachment {
          + attachment_id = (known after apply)
          + device_index  = (known after apply)
          + instance      = (known after apply)
        }
    }

  # aws_subnet.test_vpc_net11 will be created
  + resource "aws_subnet" "test_vpc_net11" {
      + arn                             = (known after apply)
      + assign_ipv6_address_on_creation = false
      + availability_zone               = "eu-north-1"
      + availability_zone_id            = (known after apply)
      + cidr_block                      = "192.168.11.0/24"
      + id                              = (known after apply)
      + ipv6_cidr_block_association_id  = (known after apply)
      + map_public_ip_on_launch         = false
      + owner_id                        = (known after apply)
      + tags_all                        = (known after apply)
      + vpc_id                          = (known after apply)
    }

  # aws_vpc.test_vpc will be created
  + resource "aws_vpc" "test_vpc" {
      + arn                            = (known after apply)
      + cidr_block                     = "192.168.0.0/16"
      + default_network_acl_id         = (known after apply)
      + default_route_table_id         = (known after apply)
      + default_security_group_id      = (known after apply)
      + dhcp_options_id                = (known after apply)
      + enable_classiclink             = (known after apply)
      + enable_classiclink_dns_support = (known after apply)
      + enable_dns_hostnames           = (known after apply)
      + enable_dns_support             = true
      + id                             = (known after apply)
      + instance_tenancy               = "default"
      + ipv6_association_id            = (known after apply)
      + ipv6_cidr_block                = (known after apply)
      + main_route_table_id            = (known after apply)
      + owner_id                       = (known after apply)
      + tags_all                       = (known after apply)
    }

Plan: 8 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + account_id      = "059999999940"
  + current_region  = "eu-north-1"
  + test1_priv_ip   = [
      + (known after apply),
      + (known after apply),
    ]
  + test1_subnet_id = [
      + (known after apply),
      + (known after apply),
    ]
  + user_id         = "AXXXXXXXXXXXXXXXXXX6Z"

───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

Note: You didn't use the -out option to save this plan, so Terraform can't guarantee to take exactly these actions if you run "terraform apply" now.
Releasing state lock. This may take a few moments...
```



### ДЗ 7.2

1.
```
      Name                    Value             Type    Location
      ----                    -----             ----    --------
   profile                <not set>             None    None
access_key     ****************PAF5              env
secret_key     ****************EM61              env
    region               eu-north-1      config-file    ~/.aws/config
```
	
2.
Packer\
https://github.com/town0wl/devops-netology/tree/main/terraform


### ДЗ 7.1
1.
Будем использовать то, что уже умеем, - Terraform, Packer, Docker, Kubernetes и Teamcity. Этого должно быть достаточно. Если условия сетевой и административной изоляции позволяют, поднимем на уже готовом кластере Kubernetes, но можно и новый запустить.\
Какой тип инфраструктуры будем использовать для этого проекта: изменяемый или не изменяемый? - Для прода будем использовать неизменяемый тип инфраструктуры.\
Будет ли центральный сервер для управления инфраструктурой? - Kubernetes master\
Будут ли агенты на серверах? - kubectl\
Будут ли использованы средства для управления конфигурацией или инициализации ресурсов? - Будут средства инициализации ресурсов: Terraform либо будут использоваться уже активные ноды Kubernetes, Kubernetes. Средства для управления конфигурацией не будут использоваться, но могут быть внедрены позже при возникновении осознанной необходимости их использования.

2.
```
root@vagrant:~# terraform --version
Terraform v1.1.2
on linux_amd64
```

3.
```
root@vagrant:~# terraform --version && /opt/terraform --version
Terraform v1.1.2
on linux_amd64
Terraform v0.12.31

Your version of Terraform is out of date! The latest version
is 1.1.2. You can update by downloading from https://www.terraform.io/downloads.html
```
