### ДЗ 10.3

1.
![alt text](https://github.com/town0wl/devops-netology/blob/main/data_sources.jpg?raw=true)

2.
Утилизация CPU для nodeexporter (в процентах, 100-idle):
```
100 - (avg by (instance) (rate(node_cpu_seconds_total{instance="$host",mode="idle"}[20s]))*100)
```
CPULA 1/5/15:
```
100 - (avg by (instance) (rate(node_cpu_seconds_total{instance="$host",mode="idle"}[1m]))*100)
100 - (avg by (instance) (rate(node_cpu_seconds_total{instance="$host",mode="idle"}[5m]))*100)
100 - (avg by (instance) (rate(node_cpu_seconds_total{instance="$host",mode="idle"}[15m]))*100)
```
Количество свободной оперативной памяти:
```
node_memory_MemFree_bytes{instance="$host"}
```
Количество места на файловой системе:
```
node_filesystem_avail_bytes{instance="$host",mountpoint="/"}
```
![alt text](https://github.com/town0wl/devops-netology/blob/main/dashboard.jpg?raw=true)

3.
С алертами:  
![alt text](https://github.com/town0wl/devops-netology/blob/main/alerts.jpg?raw=true)

4.
https://github.com/town0wl/devops-netology/blob/main/netoboard.json



### ДЗ 10.2

1.  
Pull:  
\+ Можно собирать метрики, проверяемые со стороны клиента (нпр. запросы к веб-интерфейсу)  
\+ Более простое и быстрое изменение параметров процесса сбора данных, можно регулировать загрузку сервера мониторинга  
\- Дополнительный сетевой сервис на контролируемых хостах - требуется своевременная установка обновлений  

Push:  
\+ Возможность индивидуальной конфигурации собираемой информации и параметров передачи в агентах на контролируемых хостах  
\- Может быть "завален" фейковыми данными, если не предусмотрена или ненадежна верификация данных с агентов  


2.
Prometheus - Pull (дорабатывается до Push с Pushgateway)  
TICK - основная Push, также может Pull  
Zabbix - Push/Pull  
VictoriaMetrics - Push(default)/Pull  
Nagios - Push  


3.
```
$ curl -I http://localhost:8086/ping
HTTP/1.1 204 No Content
Content-Type: application/json
Request-Id: eeb60357-8dcf-11ec-8088-0242ac160003
X-Influxdb-Build: OSS
X-Influxdb-Version: 1.8.10
X-Request-Id: eeb60357-8dcf-11ec-8088-0242ac160003
Date: Mon, 14 Feb 2022 19:54:34 GMT

$ curl http://localhost:8888
<!DOCTYPE html><html><head><meta http-equiv="Content-type" content="text/html; charset=utf-8"><title>Chronograf</title><link rel="icon shortcut" href="/favicon.fa749080.ico"><link rel="stylesheet" href="/src.14d28054.css"></head><body> <div id="react-root" data-basepath=""></div> <script src="/src.bb2cd140.js"></script> </body></html>

$ curl -I http://localhost:9092/kapacitor/v1/ping
HTTP/1.1 204 No Content
Content-Type: application/json; charset=utf-8
Request-Id: f9cd3c05-8dcf-11ec-8079-000000000000
X-Kapacitor-Version: 1.6.3
Date: Mon, 14 Feb 2022 19:54:53 GMT
```

![alt text](https://github.com/town0wl/devops-netology/blob/main/chronograf_start.jpg?raw=true)


4.
Метрики утилизации места на диске  
![alt text](https://github.com/town0wl/devops-netology/blob/main/disk_usage.jpg?raw=true)

5.
Метрики, связанные с docker  
![alt text](https://github.com/town0wl/devops-netology/blob/main/telegraf_docker.jpg?raw=true)
