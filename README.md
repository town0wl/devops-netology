### ДЗ 6.5

1.
Докерфайл:
```
FROM centos:7

RUN for iter in {1..10}; do \
    yum update --setopt=tsflags=nodocs -y && \
    yum install --setopt=tsflags=nodocs -y \
    perl-Digest-SHA \
    wget \
	&& yum clean all && \
	exit_code=0 && break || exit_code=$? && echo "yum error: retry $iter in 10s" && sleep 10; \
    done;

RUN groupadd -g 1000 elasticsearch && \
    adduser -u 1000 -g 1000 -G 0 -d /opt/elastic elasticsearch && \
    wget --no-verbose https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-7.16.0-linux-x86_64.tar.gz && \
    echo '244a19805216000752564a52fcd1c5840af6089d46401acb87dbb13efb454a78153512df027b622e23b5498fcb742d8607ab0a856e695fe8fa2c6d1daaf40cab  elasticsearch-7.16.0-linux-x86_64.tar.gz' > elasticsearch-7.16.0-linux-x86_64.tar.gz.sha512 && \
    shasum -a 512 -c elasticsearch-7.16.0-linux-x86_64.tar.gz.sha512 && \
    tar -xzf elasticsearch-7.16.0-linux-x86_64.tar.gz -C /opt/elastic --strip-components=1 && \
    rm -f elasticsearch-7.16.0-linux-x86_64.tar.gz && \
    chmod 0775 /opt/elastic && \
    chown -R 1000:0 /opt/elastic
	
RUN mkdir /var/lib/elastic && \
	mv /opt/elastic/config /var/lib/elastic/ && \ 	
	mkdir /var/lib/elastic/data && \ 
	# may be mounted to log dir on the host:
	mkdir /var/lib/elastic/logs && \ 
	# base config, may be mounted and redacted:
	echo 'node.name: netology_test' > /var/lib/elastic/config/elasticsearch.yml && \ 
	echo 'path.data: /var/lib/elastic/data' >> /var/lib/elastic/config/elasticsearch.yml && \ 
	echo 'path.logs: /var/lib/elastic/logs' >> /var/lib/elastic/config/elasticsearch.yml && \ 
	echo 'network.host: 0.0.0.0' >> /var/lib/elastic/config/elasticsearch.yml && \ 
	echo 'discovery.type: single-node' >> /var/lib/elastic/config/elasticsearch.yml && \ 
	chown -R 1000:0 /var/lib/elastic

USER elasticsearch
ENV ELASTIC_CONTAINER=true
ENV PATH=/opt/elastic:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
ENV ES_PATH_CONF=/var/lib/elastic/config
EXPOSE 9200
VOLUME ["/var/lib/elastic/data"]

ENTRYPOINT ["/opt/elastic/bin/elasticsearch"]
```
Ссылка на образ:
https://hub.docker.com/layers/town0wl/netology-repo/elastic-test-edition/images/sha256-8590ab3aa5c76751f68596c3818763c1e7a5576e9b656ce25fc585dd569e90dc?context=explore \
Статус кластера:
```
root@vagrant:/home/vagrant/elastic# curl 127.0.0.1:19200
{
  "name" : "netology_test",
  "cluster_name" : "elasticsearch",
  "cluster_uuid" : "u_N59b1BR2a6RsL1kRm6tQ",
  "version" : {
    "number" : "7.16.0",
    "build_flavor" : "default",
    "build_type" : "tar",
    "build_hash" : "6fc81662312141fe7691d7c1c91b8658ac17aa0d",
    "build_date" : "2021-12-02T15:46:35.697268109Z",
    "build_snapshot" : false,
    "lucene_version" : "8.10.1",
    "minimum_wire_compatibility_version" : "6.8.0",
    "minimum_index_compatibility_version" : "6.0.0-beta1"
  },
  "tagline" : "You Know, for Search"
}
```

2.
```
root@vagrant:/home/vagrant/elastic# curl 127.0.0.1:19200/_cat/indices
green  open .geoip_databases 09I5voUYTJq8SFXEM2qALQ 1 0 42 0 41.2mb 41.2mb
green  open ind-1            PmIt1SkyQnKfoMF20nGiyg 1 0  0 0   226b   226b
yellow open ind-3            BCrF2we_QSivgq0O5H_AHA 4 2  0 0   904b   904b
yellow open ind-2            ZwcW_AsgTnK0JmXAnJv4Cg 2 1  0 0   452b   452b
```

В параметрах индексов ind-2 и ind-3 заявлено наличие 1 и более реплик, которые кластер не может создать, так как в нем только 1 нода. Все хранимые данные в кластере есть и доступны, поэтому он в рабочем состоянии, но заданное резервирование данных не обеспечено, - это yellow.


3.
Регистрируем репозиторий:
```
root@vagrant:/home/vagrant/elastic# curl -X PUT "10.0.2.15:19200/_snapshot/netology_backup?pretty" -H 'Content-Type: application/json' -d'
> {
>   "type": "fs",
>   "settings": {
>     "location": "/var/lib/elastic/snapshots",
>     "compress": true
>   }
> }
> '
{
  "acknowledged" : true
}
```
Создан индекс test:
```
root@vagrant:/home/vagrant/elastic# curl 10.0.2.15:19200/_cat/indices
green open test 41VzDLo9Sg2c7dLjUJQRMA 1 0 0 0 226b 226b
```
Список файлов после создания снепшота:
```
root@vagrant:/home/vagrant/elastic# docker exec els-test5_2 bash -c 'ls /var/lib/elastic/snapshots'
index-0
index.latest
indices
meta-pReOiBzOR0q8y_lGXJcdng.dat
snap-pReOiBzOR0q8y_lGXJcdng.dat
```
Индекс test удален, создан test-2:
```
root@vagrant:/home/vagrant/elastic# curl 10.0.2.15:19200/_cat/indices
green open test-2 GGZew0IPTwqNJuo58vKPiw 1 0 0 0 226b 226b
```
Список снепшотов в репозитории:
```
root@vagrant:/home/vagrant/elastic# curl 10.0.2.15:19200/_snapshot/netology_backup/*?verbose=false
{"snapshots":[{"snapshot":"neto_snap_2021.12.16","uuid":"pReOiBzOR0q8y_lGXJcdng","repository":"netology_backup","indices":[".ds-.logs-deprecation.elasticsearch-default-2021.12.16-000001",".ds-ilm-history-5-2021.12.16-000001","test"],"data_streams":[],"state":"SUCCESS"}],"total":1,"remaining":0}
```
Это должно работать для исключения dot-индексов при восстановлении, но не работает:
```
root@vagrant:/home/vagrant/elastic# curl -X POST "10.0.2.15:19200/_snapshot/netology_backup/neto_snap_2021.12.16/_restore" -H 'Content-Type: application/json' -d'
{
  "indices": "*,-.*"
}
'
{"error":{"root_cause":[{"type":"snapshot_restore_exception","reason":"[netology_backup:neto_snap_2021.12.16/pReOiBzOR0q8y_lGXJcdng] cannot restore index [.ds-ilm-history-5-2021.12.16-000001] because an open index with same name already exists in the cluster. Either close or delete the existing index or restore the index under a different name by providing a rename pattern and replacement name"}],"type":"snapshot_restore_exception","reason":"[netology_backup:neto_snap_2021.12.16/pReOiBzOR0q8y_lGXJcdng] cannot restore index [.ds-ilm-history-5-2021.12.16-000001] because an open index with same name already exists in the cluster. Either close or delete the existing index or restore the index under a different name by providing a rename pattern and replacement name"},"status":500}
```
Восстановление с указанием конкретных индексов:
```
root@vagrant:/home/vagrant/elastic# curl -X POST "10.0.2.15:19200/_snapshot/netology_backup/neto_snap_2021.12.16/_restore" -H 'Content-Type: application/json' -d'
{
  "indices": "test"
}
'
{"accepted":true}
```
Индексы после восстановления:
```
root@vagrant:/home/vagrant/elastic# curl 10.0.2.15:19200/_cat/indices
green open test-2 GGZew0IPTwqNJuo58vKPiw 1 0 0 0 226b 226b
green open test   u7QRUykhQ2ibI71Mk0rGsg 1 0 0 0 226b 226b
```



### ДЗ 6.1

1.
Электронные чеки в json виде - MongoDB, Elasticsearch или другая документоориентированная. Тут нужно хранить простые текстовые строковые данные, могли бы подойти и ключ-значение, но документоориентированные позволят хранить еще дополнительные свойства, сортировать и искать по ним.\
Склады и автомобильные дороги для логистической компании - графовые NoSQL, потому что идеально подходят под структуру данных. Можно и в реляционных, где есть таблица складов с их свойствами, таблица дорог с их свойствами и таблица связей между ними с их свойствами.\
Генеалогические деревья - иерархические NoSQL, потому что идеально подходят под структуру данных. В реляционных тоже можно.\
Кэш идентификаторов клиентов с ограниченным временем жизни для движка аутенфикации - простой список данных, пользователь данных выполняет конкретную частную задачу, долговременное хранение не требуется, а хорошая скорость не помешает - ключ-значение NoSQL.\
Отношения клиент-покупка для интернет-магазина - отношения это прямо таки реляционная тема. Но можно и в документориентированных хранить, и в графовых. Реляционные следует выбрать при большом количестве других хранимых данных, или его возможности в будущем, а также при больших общих объемах данных. Документориентированные - если объемы неболшие и/или сервис динамично развивающийся и/или заранее неизвестны возможные форматы данных. 

2.
C (consistency) — согласованность. Каждое чтение даст вам самую последнюю запись.\
A (availability) — доступность. Каждый узел (не упавший) всегда успешно выполняет запросы (на чтение и запись).\
P (partition tolerance) — устойчивость к распределению. Даже если между узлами нет связи, они продолжают работать независимо друг от друга.

if (P, then A or C, else L or C)\
1\. При сетевом разделении система или консистентна, или доступна.\
2\. Без сетевого разделения – или консистентна, или обеспечивает высокую скорость ответа.

Данные записываются на все узлы с задержкой до часа (асинхронная запись) - Данные не согласованы из-за асинхронной записи - AP; P?(неизвестно)/EL\
При сетевых сбоях, система может разделиться на 2 раздельных кластера - Система продолжает работать при разделении, но данные будут несогласованы - AP; PA/E?(неизвестно)\
Система может не прислать корректный ответ или сбросить соединение - CP; PC/EC

3.
Одновременно - нет. Потому что смысл BASE - избавиться от ограничений производительности, накладываемых ACID. Но может быть компромисс между ними, сбалансированный под специфику задач.

4.
Redis\
Минусы: динамично развивается, поэтому выходит много исправлений и обновлений, в том числе устраняющих уязвимости; требует настройки для обеспечения безопасности.\
Другие свойства: имеет хорошую реализацию pub/sub с высокой производительностью, позволяет сохранять данные на диск для исключения потери при падении, может быть организована в кластеры, открытый код, бесплатна.
