### ДЗ 4.1

1.
c будет содержать строку 'a+b', так как ей присваивается это значение (a и b не интерпретируются как переменные без знака $)\
d будет содержать строку '1+2', так как вместо $a и $b подставляются значения переменных\
e будет содержать 3 - результат выполнения арифметической операции над $a и $b, так как инициируется вызов команды, выполняющей сложение

2.
В скрипте не предусмотрен выход из цикла. Можно добавить 'else break;' перед 'fi'. Также не помешает sleep между итерациями. Еще можно укорачивать файл, чтобы не забивать место на диске, например, 'tail -n 100 curl.log > curl.log'.

3.
```
#!/usr/bin/env bash
ips=(64.233.164.113 173.194.222.113 87.250.250.242)
for i in {1..5}
do
for ip in ${ips[@]}
do
nc -nvz -w 1 ${ip} 80 2>>access80.log || sleep 1
done
done
```

Или конкретный сервис (HTTP, например):
```
#!/usr/bin/env bash
ips=(64.233.164.113 173.194.222.113 87.250.250.242)
for i in {1..5}
do
for ip in ${ips[@]}
do
if (curl --connect-timeout 1 http://${ip}:80 1>/dev/null 2>&1)
then 
echo "$(date) + ${ip} is accessible" >> access80.log
sleep 1
else 
echo "$(date) - ${ip} is not accessible" >> access80.log
fi
done
done
```

4.
```
#!/usr/bin/env bash
ips=(64.233.164.113 173.194.222.113 87.250.250.242)
while true
do
for ip in ${ips[@]}
do
nc -nvz -w 1 ${ip} 80 2>/dev/null	# curl --connect-timeout 1 http://${ip}:80 1>/dev/null 2>&1
if (($?))
then
echo "$(date) - ${ip} port 80 is not accessible" >> error80.log
break 2
fi
done
sleep 1
done
```


### ДЗ 3.8

1.
В графе InActConn учтены все отслеживаемые соединения, которые не находятся в состоянии ESTABLISHED . Так как в режимах DR и туннелирования через директор проходят только пакеты, направленные от клиента к серверу, он не может отследить полноценное завершение TCP-соединения. После выхода из состояния ESTABLISHED соединение добавляется к InActConn на время таймаута.

2.
```
boxes = {
  'client' => '5',
  'director1' => '11',
  'director2' => '12',
  'nginx1' => '21',
  'nginx2' => '22',
}

root@client:/home/vagrant# for i in {1..100}; do curl -Is http://172.17.17.10 | grep HTTP; done
HTTP/1.1 200 OK
HTTP/1.1 200 OK
...

root@director1:/home/vagrant# ipvsadm -Ln --stats
IP Virtual Server version 1.2.1 (size=4096)
Prot LocalAddress:Port               Conns   InPkts  OutPkts  InBytes OutBytes
  -> RemoteAddress:Port
TCP  172.17.17.10:80                   101      606        0    40097        0
  -> 172.17.17.21:80                    50      300        0    19850        0
  -> 172.17.17.22:80                    51      306        0    20247        0
  
root@director1:/home/vagrant# cat /etc/keepalived/keepalived.conf
vrrp_instance VI_1 {
   state MASTER
   interface eth1
   virtual_router_id 10
   priority 100
   advert_int 10
   authentication {
       auth_type PASS
       auth_pass 1111
   }
   virtual_ipaddress {
      172.17.17.10
  }
}

root@director2:/home/vagrant# ipvsadm -Ln --stats
IP Virtual Server version 1.2.1 (size=4096)
Prot LocalAddress:Port               Conns   InPkts  OutPkts  InBytes OutBytes
  -> RemoteAddress:Port
TCP  172.17.17.10:80                     0        0        0        0        0
  -> 172.17.17.21:80                     0        0        0        0        0
  -> 172.17.17.22:80                     0        0        0        0        0
  
root@director2:/home/vagrant# cat /etc/keepalived/keepalived.conf
vrrp_instance VI_1 {
   state BACKUP
   interface eth1
   virtual_router_id 10
   priority 50
   advert_int 10
   authentication {
       auth_type PASS
       auth_pass 1111
   }
   virtual_ipaddress {
      172.17.17.10
  }
}

root@nginx1:/home/vagrant# sysctl net.ipv4.conf.all.arp_ignore
ipv4.connet.ipv4.conf.all.arp_ignore = 1
f.all.arroot@nginx1:/home/vagrant# sysctl net.ipv4.conf.all.arp_announce
net.ipv4.conf.all.arp_announce = 2
root@nginx1:/home/vagrant# ip a l lo
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet 172.17.17.10/32 scope global lo:10
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
root@nginx1:/home/vagrant# wc -l /var/log/nginx/access.log
51 /var/log/nginx/access.log

root@nginx2:/home/vagrant# sysctl net.ipv4.conf.all.arp_ignore
net.ipv4.conf.all.arp_ignore = 1
root@nginx2:/home/vagrant# sysctl net.ipv4.conf.all.arp_announce
net.ipv4.conf.all.arp_announce = 2
root@nginx2:/home/vagrant# ip a l lo
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet 172.17.17.10/32 scope global lo:10
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
root@nginx2:/home/vagrant# wc -l /var/log/nginx/access.log
52 /var/log/nginx/access.log
```

Отключим keepalived на Master:

```
root@director1:/home/vagrant# systemctl stop keepalived
root@director1:/home/vagrant# systemctl status keepalived
● keepalived.service - Keepalive Daemon (LVS and VRRP)
     Loaded: loaded (/lib/systemd/system/keepalived.service; enabled; vendor preset: enabled)
     Active: inactive (dead) since Sun 2021-07-11 13:54:55 UTC; 7s ago
    Process: 13846 ExecStart=/usr/sbin/keepalived --dont-fork $DAEMON_ARGS (code=exited, status=0/SUCCESS)
   Main PID: 13846 (code=exited, status=0/SUCCESS)

root@client:/home/vagrant# for i in {1..100}; do curl -Is http://172.17.17.10 | grep HTTP; done
HTTP/1.1 200 OK
HTTP/1.1 200 OK
...

root@director2:/home/vagrant# ipvsadm -Ln --stats
IP Virtual Server version 1.2.1 (size=4096)
Prot LocalAddress:Port               Conns   InPkts  OutPkts  InBytes OutBytes
  -> RemoteAddress:Port
TCP  172.17.17.10:80                   100      600        0    39700        0
  -> 172.17.17.21:80                    50      300        0    19850        0
  -> 172.17.17.22:80                    50      300        0    19850        0
  
root@nginx1:/home/vagrant# wc -l /var/log/nginx/access.log
101 /var/log/nginx/access.log

root@nginx2:/home/vagrant# wc -l /var/log/nginx/access.log
102 /var/log/nginx/access.log
```

3.
Ответ: 6 (3!).\
Можно использовать 3 адреса: каждый из директоров будет мастером для одного и вторым приоритетов для другого. Тогда при падении одного условные две трети нагрузки пойдут на один из оставшихся и одна треть - на второй. Две трети от 1.5 Гбит/с это 1 Гбит/с - весь канал, так что могут быть потери.\
Если использовать 6 адресов со всеми возможными для 3х директоров различными последовательностями приоритетов, то при падении одного директора нагрузка равномерно распредилится на два оставшихся.


### ДЗ 3.7

1.
Если отправитель не получает ответа за время, пока он отсылает данные в размере окна, он приостанавливает отправку. Для достижения время отправки данных в размере окна должно быть равно или больше RTT. Т.е.:\
(размер окна)/(1 Гбит/с) >= 300мс\
размер окна >= 38.4 МБ\
В оригинальном TCP Window Size – 16 битное число, которое обозначает размер окна в байтах, - максимум 65535 байт. Есть дополнительная опция Window scale, которая позволяет увеличить размер окна до 1 Гбайта. Чтобы задействовать эту опцию, обе стороны должны согласовать это в своих SYN сегментах.

2.
Если присутствует 1% потерь пакетов, то этот 1% пакетов потребуется переслать повторно. А далее 1% от этих пакетов и так далее, но пренебрежем этим, т.к. этот вклад на 2 и более порядков меньше. Итого передача заданного количества пакетов займет в 1,01 больше времени, т.е. скорость упадет в 1,01 раза.

3.
Каждый пакет, содержащий MSS полезных данных, будет реально требовать передачи (MSS + 20 байт (или больше) заголовка TCP + 20 байт (или больше) заголовка IP + 36 байт (или больше) служебных Ethernet). Если рассматривать MSS 1460 байт, то полезные данные будут составлять 95% передаваемых данных или менее, т.е. максимальная скорость передачи данных будет около 95 Мбит/с. Если увеличить размер фрейма, можно достичь более близкой к 100 Мбит/с скорости, если уменьшить размер фрейма - можно существенно снизить скорость.

4.
curl -I http://netology.ru \
Так как netology.ru нет в кеше DNS, также в hosts, надо определить IP - отправить запрос к установленному DNS. Допустим, DNS находится в локальном сегменте. Нужно получить MAC DNS:\
хост берет адрес DNS-сервера из конфигурации\
хост определяет по таблице роутинга на какой интефейс обращаться к DNS-серверу\
хост по маске сети определяет, что DNS находится в локальном сегменте\
хост отправляет широковещательный ARP-запрос с IP DNS\
хост получает ответ с MAC-адресом DNS\
хост открывает UDP сокет и отправляет DNS-запрос в UDP (53) на IP DNS на MAC DNS\
хост получает ответ на открытый UDP сокет и закрывает его\
хост определяет по таблице роутинга на какой интефейс обращаться к netology.ru и видит, что он за маршрутизатором\
хост отправляет широковещательный ARP-запрос с IP маршрутизатора\
приходит ответ с MAC-адресом маршрутизатора\
хост открывает TCP сокет и инициирует TCP-соединение с netology.ru, отправив SYN в TCP (80) на IP netology.ru на MAC маршрутизатора\
после установки сессии TCP хост отправляет в сокет HTTP-запрос\
хост получает HTTP-ответ и закрывает сокет

5.
3 запроса: к корневому серверу, к TLD и к серверу зоны запрашиваемого имени, например:\
dig www.google.co.uk. @a.root-servers.net.\
dig www.google.co.uk. @dns1.nic.uk.\
dig www.google.co.uk. @ns1.google.com.

6.
в /25 - 126 адресов для хостов\
в 255.248.0.0 - 524 286

7.
В подсети с маской /23 больше адресов, чем с /24

8.
Минимальная подсеть, куда вмещаются 131070 адресов, - /15. В диапазоне 10.0.0.0/8 можно выделить как раз максимум 128 таких подсетей. Т.е. разделить получится.






### ДЗ 3.6

2.
Всего 14 каналов на частоте 2.4 ГГц, но 14й используется только в Японии. В Северной Америке ограничено использование каналов 12 и 13. В любом случае можно выделить 3 непересекающихся канала, например, 1, 6 и 11.

3.
38:f9:d3\
Apple, Inc.

4.
До 8949 байт включительно.

5.
Нет, т.к. SYN сигнализирует об открытии соединения, FIN - о закрытии соединения, а случая совместного использования этих флагов не предусмотрено.

6.
В выводе информация о сокете UDP, т.к. указан флаг -u. В UDP нет сессии, поэтому нет состояний сессий: TIME-WAIT, CONN и прочих. 

7.
ESTAB - ESTAB\
  FIN ->\
Инициатор закрытия отправляет FIN и переходит в состояние FIN-WAIT-1. Ответчик после получения FIN переходит в состояние CLOSE-WAIT.\
FIN-WAIT-1 - CLOSE-WAIT\
   <- ACK\
Ответчик отправляет ACK в ответ на FIN инициатора. При получении этого ACK инициатор переходит в FIN-WAIT-2. Ответчик досылает оставшиеся данные.\
FIN-WAIT-2 - CLOSE-WAIT\
   <- FIN\
Завершив передачу, ответчик отправляет FIN и переходит в состояние LAST-ACK. Инцииатор, получив FIN, отправляет ACK ответчику и переходит в состояние TIME-WAIT.\
TIME-WAIT - LAST-ACK\
  -> ACK\
Ответчик, получив ACK в ответ на FIN, закрывает соединение. Инициатор закрывает соединение спустя таймаут с отправки последнего ACK.\
TIME-WAIT - CLOSED\
  \<timeout>\
CLOSED - CLOSED

8.
Если рассматривать протокол TCP. Теоретическое максимальное число соединений, ограниченное только лишь параметрами L4, которое параллельно может установить клиент с одного IP адреса к серверу с одним IP адресом, - 65535. Такое же теоретическое максимальное количество соединений от одного клиента (IP), которое может одновременно обслуживать сервер; но ограничено имеено тем, что клиент не может открыть больше. Сервер использует общие сокеты TCP для разных клиентов, поэтому общее количество соединений не ограничено параметрами L4, а ограничено архитектурой и ресурсами серверного приложения.

9.
TIME-WAIT возникает только у инициатора завершения соединения, обычно это клиент, после получения FIN с другой стороны. Если возникло много TIME-WAIT, значит, хост инициировал закрытие большого количества соединений, закрытия прошли успешно и еще не прошел таймаут TIME_WAIT. Сеть работает корректно, но порты, занятые соединениями TIME-WAIT, не доступны, пока соединение не закроется, что может стать проблемой нехватки свободных портов TCP. Можно уменьшить таймаут /proc/sys/net/ipv4/tcp_fin_timeout или увеличить диапазон разрешенных клиентских портов /proc/sys/net/ipv4/ip_local_port_range. 

10.
В UDP отсуствует нумерация сегментов. Получатель не знает о потерянных сегментах и не может проконтролировать целостность полученных данных и определить потерянные участки (без дополнительной работы со стороны вышестоящего протокола).

11.
RELP (TCP), потому что обеспечивает доставку без потерь.

12.
```
# ss -anltp
State            Recv-Q           Send-Q                     Local Address:Port                       Peer Address:Port           Process
LISTEN           0                4096                             0.0.0.0:111                             0.0.0.0:*               users:(("rpcbind",pid=552,fd=4),("systemd",pid=1,fd=35))
LISTEN           0                4096                       127.0.0.53%lo:53                              0.0.0.0:*               users:(("systemd-resolve",pid=553,fd=13))
LISTEN           0                128                              0.0.0.0:22                              0.0.0.0:*               users:(("sshd",pid=2050,fd=3))
LISTEN           0                4096                                [::]:111                                [::]:*               users:(("rpcbind",pid=552,fd=6),("systemd",pid=1,fd=37))
LISTEN           0                128                                 [::]:22                                 [::]:*               users:(("sshd",pid=2050,fd=4))
```

13.
В текстовом виде - -A.\
В тектовом и hex - -X или -XX (с включением заголовков канального уровня).

14.
Встретился флаг: 0x40, Don't fragment\
Всего 3 флага у IP4: 1й не используется, 2й - не фрагментировать, 3й - у пакета есть еще фрагменты.\
Ethernet II (DIX Ethernet)\
Wireshark сам подставляет значение OUI по MAC адресу, например: PcsCompu_e3:90:c5 (08:00:27:e3:90:c5)
