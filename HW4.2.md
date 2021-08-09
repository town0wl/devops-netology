## ДЗ 4.2
1.
В изначальном варианте переменной c не будет присвоено никакое значение (переменная останется not defined), попытка сложения числа со строкой закончится ошибкой о том, что такие операции не поддерживаются: unsupported operand type(s) for +: 'int' and 'str'\
Получить 12:\
c = int(str(a) + b)\
Получить 3:\
c = a + int(b)

2.
```
#!/usr/bin/env python3

import os

bash_command = ["cd ~/netology/sysadm-homeworks", "pwd", "git status --porcelain"]
result_os = os.popen(' && '.join(bash_command)).read()
result = ''
lines = result_os.strip().split('\n')
pwd = lines[0].strip()
for line in lines[1:]:
    result += pwd + '/' + line[3:] + '\n'

print(result.strip())
```

3.
```
#!/usr/bin/env python3

import os
import sys

if (len(sys.argv) != 2):
    print('Usage: ./script <directory>')
    exit(1)

if (not os.path.isdir(os.path.expanduser(sys.argv[1]))):
    print('Error: not a directory')
    exit(3)

bash_command = ["cd " + sys.argv[1], "pwd", "git status --porcelain 2>&1"]
result_os = os.popen(' && '.join(bash_command)).read()

if ('fatal: not a git repository' in result_os):
    print('Error: not a git repository')
    exit(5)

result = ''
lines = result_os.strip().split('\n')
pwd = lines[0].strip()
for line in lines[1:]:
    result += pwd + '/' + line[3:] + '\n'

print(result.strip())
```

4.
```
#!/usr/bin/env python3

import re
import socket

ips = {'drive.google.com': '', 'mail.google.com': '', 'google.com': ''}

for name in ips.keys():
    ip = socket.gethostbyname(name)
    print(name + ' ' + ip)
    if (ip != ips[name]):
        if (ips[name] != ''): print('[ERROR] {0} IP mismatch: {1} {2}'.format(name, ips[name], ip))
        ips[name] = ip


fin = open(__file__, 'r')
code = fin.read()
fin.close()

code = re.sub('^ips = {.*}$', 'ips = ' + repr(ips), code, 0, re.MULTILINE)

fout = open(__file__, 'w')
fout.write(code)
fout.close()
```
