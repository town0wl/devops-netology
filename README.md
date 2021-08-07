### ДЗ 4.3
1.
```
{ "info" : "Sample JSON output from our service\t",
    "elements" : [
        { "name" : "first",
        "type" : "server",
        "ip" : 7175 
        },
        { "name" : "second",
        "type" : "proxy",
        "ip" : "71.78.22.43"
        }
    ]
}
```

2.
```
#!/usr/bin/env python3

import socket
import json
import yaml

names = ['drive.google.com', 'mail.google.com', 'google.com']
ips = {}
old = {}

try:
    with open('ips.yaml','r') as yml:
        old = yaml.safe_load(yml)
except OSError as e:
    print(e)

for name in names:
    ip = socket.gethostbyname(name)
    print(name + ' ' + ip)
    ips[name] = ip
    if (name in old.keys() and old[name] != '' and ip != old[name]): print('[ERROR] {0} IP mismatch: {1} {2}'.format(name, old[name], ip))

with open('ips.yaml','w') as yml:
    yml.write(yaml.dump(ips))
    
with open('ips.json','w') as jsonfile:
    json.dump(ips, jsonfile)
```

3.
```
#!/usr/bin/env python3

import json
import yaml
import sys
import re

def try_read_yaml(text):
    try:
        data = yaml.safe_load(text)
        return True, data
    except Exception as e:
        return False, e

def try_read_json(text):
    try:
        data = json.loads(text)
        return True, data
    except ValueError as e:
        result = str(e)
        t = re.search(' line (\d+) ', result)
        if (t): result += '\n' + text.split('\n')[int(t.group(1))-1]
        return False, result
    except Exception as e:
        return False, e

def yaml_detected(data):
    print('YAML detected\n' + repr(data))
    ## To check whether file exists and ask
    filename = re.sub('\.[^.]*$', '', sys.argv[1]) + '.json'
    with open(filename, 'w') as new_json:
        new_json.write(json.dumps(data))

def json_detected(data):
    print('JSON detected:\n' + repr(data))
    ## To check whether file exists and ask
    filename = re.sub('\.[^.]*$', '', sys.argv[1]) + '.yml'
    with open(filename, 'w') as new_yml:
        new_yml.write(yaml.dump(data))


if __name__ == '__main__':

    if (len(sys.argv) != 2):
        print('Usage: ./script <file>')
        exit(1)

    # Censorship
    if (not re.search('\.(json|yml)$', sys.argv[1])):
        print('Incorrect filename')
        exit(3)

    try:
        with open(sys.argv[1],'r') as file:
            text = file.read()
    except OSError as e:
        print('Ooh\n' + str(e))
        exit(7)

    if (text[0]=='{'):
        # Suppose JSON
        json, j_data = try_read_json(text)
        if (json):
            json_detected(j_data)
        else:
            yaml, y_data = try_read_yaml(text)
            if (yaml):
                yaml_detected(y_data)
            else:
                print('JSON reading error:')
                print(j_data)

    else:
        # Not a JSON, suppose YAML
        yaml, y_data = try_read_yaml(text)
        if (yaml):
            yaml_detected(y_data)
        else:
            print('YAML reading error:')
            print(y_data)
```

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
