### ДЗ 6.4

1.
```
\l[+]   [PATTERN]      list databases
\c[onnect] {[DBNAME|- USER|- HOST|- PORT|-] | conninfo}	connect to new database (currently "main_db")
\dt[S+] [PATTERN]      list tables
\d[S+]  NAME           describe table, view, sequence, or index
\q                     quit psql
```

2.
```
select attname from pg_stats where tablename='orders' and avg_width=(select MAX(avg_width) from pg_stats where tablename='orders')

 attname
---------
 title
(1 row)
```

3.
```
BEGIN;
create table orders_1 ( check ( price > 499 ) ) inherits (orders);
create rule send_to_orders_1 as on insert to orders where (price > 499) do instead insert into orders_1 values (new.*);
create table orders_2 ( check ( price <= 499 ) ) inherits (orders);
create rule send_to_orders_2 as on insert to orders where (price <= 499) do instead insert into orders_2 values (new.*);
insert into orders_1 select * from only orders where price > 499;
insert into orders_2 select * from only orders where price <= 499;
truncate only orders;
COMMIT;
```

Можно сразу создать таблицу секционированной при выполнении CREATE TABLE с параметром PARTITION BY (декларативное партиционирование/секционирование). В таком случае она не будет непосредственно содержать данные, а будет представлять собой консолидацию данных из таблиц-партиций. При этом таблицы-партиции все равно нужно создавать вручную, хотя можно сформировать скрипт для выполнения этой задачи. При таком способе партицирования, начиная с 11й версии, создание индекса на родительской таблице автоматически приводит к созданию индексов для всех существующих и новых партиций, которые будут созданы в будущем.

4.
Как бы вы доработали бэкап-файл, чтобы добавить уникальность значения столбца title для таблиц test_database? - Пока непонятно, как это сделать. При декларативном секционировании требуется, чтобы ключ секционирования входил в уникальный индекс, но это не подходит, т.к. уникальным должен быть именно 'title'. При наследовании с этим вообще функциональные сложности. Надо использовать триггер?


### ДЗ 6.2

1.
```
services:
  postgres:
    image: "postgres:12"
    ports:
      - "5432:5432/tcp"
    volumes:
      - postgres-data:/var/lib/postgresql/data
      - postgres-backup:/var/lib/postgres-backup
    environment:
      POSTGRES_USER: user
      POSTGRES_PASSWORD: password
      POSTGRES_DB: main_db
volumes:
  postgres-data:
  postgres-backup:
```
  
2.
Список БД:
```
  datname
-----------
 postgres
 main_db
 template1
 template0
 test_db
(5 rows)
```

Описание таблицы orders:
```
                                                   Table "public.orders"
    Column    |  Type   | Collation | Nullable |              Default               | Storage  | Stats target | Description
--------------+---------+-----------+----------+------------------------------------+----------+--------------+-------------
 id           | integer |           | not null | nextval('orders_id_seq'::regclass) | plain    |              |
 наименование | text    |           | not null |                                    | extended |              |
 цена         | integer |           |          |                                    | plain    |              |
Indexes:
    "orders_pkey" PRIMARY KEY, btree (id)
Referenced by:
    TABLE "clients" CONSTRAINT "clients_заказ_fkey" FOREIGN KEY ("заказ") REFERENCES orders(id)
Access method: heap
```
	
Описание таблицы clients:
```
                                                      Table "public.clients"
      Column       |  Type   | Collation | Nullable |               Default               | Storage  | Stats target | Description
-------------------+---------+-----------+----------+-------------------------------------+----------+--------------+-------------
 id                | integer |           | not null | nextval('clients_id_seq'::regclass) | plain    |              |
 фамилия           | text    |           | not null |                                     | extended |              |
 страна проживания | text    |           | not null |                                     | extended |              |
 заказ             | integer |           |          |                                     | plain    |              |
Indexes:
    "clients_pkey" PRIMARY KEY, btree (id)
    "clients_lower_idx" btree (lower("страна проживания"))
Foreign-key constraints:
    "clients_заказ_fkey" FOREIGN KEY ("заказ") REFERENCES orders(id)
Access method: heap
```

Права доступа к таблицам (SQL-запрос и список пользователей с правами):
```
test_db=# SELECT table_name, grantee, privilege_type FROM information_schema.role_table_grants WHERE table_name='orders' OR table_name='clients';
 table_name |     grantee      | privilege_type
------------+------------------+----------------
 orders     | user             | INSERT
 orders     | user             | SELECT
 orders     | user             | UPDATE
 orders     | user             | DELETE
 orders     | user             | TRUNCATE
 orders     | user             | REFERENCES
 orders     | user             | TRIGGER
 orders     | test-simple-user | INSERT
 orders     | test-simple-user | SELECT
 orders     | test-simple-user | UPDATE
 orders     | test-simple-user | DELETE
 orders     | test-admin-user  | INSERT
 orders     | test-admin-user  | SELECT
 orders     | test-admin-user  | UPDATE
 orders     | test-admin-user  | DELETE
 orders     | test-admin-user  | TRUNCATE
 orders     | test-admin-user  | REFERENCES
 orders     | test-admin-user  | TRIGGER
 clients    | user             | INSERT
 clients    | user             | SELECT
 clients    | user             | UPDATE
 clients    | user             | DELETE
 clients    | user             | TRUNCATE
 clients    | user             | REFERENCES
 clients    | user             | TRIGGER
 clients    | test-simple-user | INSERT
 clients    | test-simple-user | SELECT
 clients    | test-simple-user | UPDATE
 clients    | test-simple-user | DELETE
 clients    | test-admin-user  | INSERT
 clients    | test-admin-user  | SELECT
 clients    | test-admin-user  | UPDATE
 clients    | test-admin-user  | DELETE
 clients    | test-admin-user  | TRUNCATE
 clients    | test-admin-user  | REFERENCES
 clients    | test-admin-user  | TRIGGER
(36 rows)
```

3.
Вариант 1 - точный и медленный:
```
test_db=# SELECT count(*) AS exact_count FROM orders;
 exact_count
-------------
           5
(1 row)
```
Вариант 2 - быстрый (если уже выполнен analyze):
```
test_db=# analyze clients;  -- or vacuum
ANALYZE
test_db=# SELECT (CASE WHEN c.reltuples < 0 THEN NULL       -- never vacuumed
test_db(#              WHEN c.relpages = 0 THEN float8 '0'  -- empty table
test_db(#              ELSE c.reltuples / c.relpages END
test_db(#       * (pg_relation_size(c.oid) / pg_catalog.current_setting('block_size')::int)
test_db(#        )::bigint as estimate
test_db-# FROM   pg_class c
test_db-# WHERE  c.oid = 'public.clients'::regclass;
 estimate
----------
        5
(1 row)
```

4.
```
update clients set "заказ" = (select id from orders where orders."наименование"='Книга') where clients."фамилия"='Иванов Иван Иванович';
update clients set "заказ" = (select id from orders where orders."наименование"='Монитор') where clients."фамилия"='Петров Петр Петрович';
update clients set "заказ" = (select id from orders where orders."наименование"='Гитара') where clients."фамилия"='Иоганн Себастьян Бах';

test_db=# select "фамилия" from clients where "заказ" is not null;
       фамилия
----------------------
 Иванов Иван Иванович
 Петров Петр Петрович
 Иоганн Себастьян Бах
(3 rows)
```

5.
```
test_db=# explain select "фамилия" from clients where "заказ" is not null;
                       QUERY PLAN
--------------------------------------------------------
 Seq Scan on clients  (cost=0.00..1.05 rows=3 width=33)
   Filter: ("заказ" IS NOT NULL)
(2 rows)

test_db=# explain analyze select "фамилия" from clients where "заказ" is not null;
                                            QUERY PLAN
--------------------------------------------------------------------------------------------------
 Seq Scan on clients  (cost=0.00..1.05 rows=3 width=33) (actual time=0.018..0.019 rows=3 loops=1)
   Filter: ("заказ" IS NOT NULL)
   Rows Removed by Filter: 2
 Planning Time: 0.102 ms
 Execution Time: 0.034 ms
(5 rows)
```

Запрос будет выполняться с помощью простого последовательного сканирования. Оценка стоимости запуска - 0.00 (затраты до начала вывода данных), оценка общей стоимости выполнения - 1.05.
Итоговое время выполнения при реальном запуске 0.034 мс.

6.
Бэкап:
```
docker exec -u postgres postgres-postgres-1 bash -c 'PGPASSWORD="$POSTGRES_PASSWORD" pg_dump -U "$POSTGRES_USER" test_db | gzip > /var/lib/postgres-backup/test_db.back.gz'
docker exec -u postgres postgres-postgres-1 bash -c 'PGPASSWORD="$POSTGRES_PASSWORD" pg_dumpall --globals-only -U "$POSTGRES_USER" | gzip > /var/lib/postgres-backup/db_cluster_data.back.gz'
```
Для нового контейнера чистый volume под данные и старый с бэкапами. Восстановление:
```
docker exec -u postgres postgres-postgres-1 bash -c 'gunzip -c /var/lib/postgres-backup/db_cluster_data.back.gz | PGPASSWORD="$POSTGRES_PASSWORD" psql -U "$POSTGRES_USER" postgres'
PGPASSFILE='/home/vagrant/postgres/.pgpass' psql -h 127.0.0.1 -p 5432 -d main_db -U user -c "create database test_db;"
docker exec -u postgres postgres-postgres-1 bash -c 'gunzip -c /var/lib/postgres-backup/test_db.back.gz | PGPASSWORD="$POSTGRES_PASSWORD" psql -U "$POSTGRES_USER" test_db'
```



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
