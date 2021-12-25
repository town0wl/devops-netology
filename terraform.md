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
