## ДЗ 3.2 дополнение
6.\
/dev/tty is a special file, representing the terminal for the current process. It is a synonym for the controlling terminal of a process, if any.\
echo 333 > /dev/tty выводит в текущий терминал, как в графическом режиме, так и без него

/dev/ttyX\
ps aux | grep tty\
root         557  0.0  0.0   5784  1732 tty1     Ss+  02:27   0:00 /sbin/agetty -o -p -- \u --noclear tty1 linux\
root         558  0.5  4.0 877740 81372 tty7     Ssl+ 02:27   0:02 /usr/lib/xorg/Xorg :0 -seat seat0 -auth /var/run/lightdm/root/:0 -nolisten tcp vt7 -novtswitch\
echo 111 > /dev/tty1 - ничего не выводится\
echo 777 > /dev/tty7 - ничего не выводится\
cat /dev/tty1 - ничего не выводится, в том числе если попользоваться графическими приложениями\
cat /dev/tty7 - ничего не выводится, в том числе если попользоваться графическими приложениями

/dev/ttySX\
ttyS0-ttyS3 write error: Input/output error\
в ttyS4 и выше можно вывести, потом прочитать\
echo 555 > /dev/ttyS4\
cat /dev/ttyS4


## ДЗ 3.4

1.\
$ systemctl cat node_exporter\
\# /etc/systemd/system/node_exporter.service\
[Unit]\
Description=Node Exporter\
Wants=network-online.target\
After=network-online.target

[Service]\
User=node_exporter\
Group=node_exporter\
Type=simple\
EnvironmentFile=-/etc/default/node_exporter\
ExecStart=/opt/node_exp/node_exporter $EXTRA_OPTS

[Install]\
WantedBy=multi-user.target

$ systemctl status node_exporter\
● node_exporter.service - Node Exporter\
     Loaded: loaded (/etc/systemd/system/node_exporter.service; enabled; vendor preset: enabled)\
     Active: active (running) since Sun 2021-06-06 06:33:25 UTC; 6min ago\
   Main PID: 783 (node_exporter)\
      Tasks: 5 (limit: 1072)\
     Memory: 12.9M\
     CGroup: /system.slice/node_exporter.service\
             └─783 /opt/node_exp/node_exporter

Jun 06 06:33:25 vagrant node_exporter[783]: level=info ts=2021-06-06T06:33:25.828Z caller=node_exporter.go:113 collector=thermal_zone\
Jun 06 06:33:25 vagrant node_exporter[783]: level=info ts=2021-06-06T06:33:25.828Z caller=node_exporter.go:113 collector=time\
Jun 06 06:33:25 vagrant node_exporter[783]: level=info ts=2021-06-06T06:33:25.828Z caller=node_exporter.go:113 collector=timex\
Jun 06 06:33:25 vagrant node_exporter[783]: level=info ts=2021-06-06T06:33:25.828Z caller=node_exporter.go:113 collector=udp_queues\
Jun 06 06:33:25 vagrant node_exporter[783]: level=info ts=2021-06-06T06:33:25.828Z caller=node_exporter.go:113 collector=uname\
Jun 06 06:33:25 vagrant node_exporter[783]: level=info ts=2021-06-06T06:33:25.828Z caller=node_exporter.go:113 collector=vmstat\
Jun 06 06:33:25 vagrant node_exporter[783]: level=info ts=2021-06-06T06:33:25.828Z caller=node_exporter.go:113 collector=xfs\
Jun 06 06:33:25 vagrant node_exporter[783]: level=info ts=2021-06-06T06:33:25.829Z caller=node_exporter.go:113 collector=zfs\
Jun 06 06:33:25 vagrant node_exporter[783]: level=info ts=2021-06-06T06:33:25.829Z caller=node_exporter.go:195 msg="Listening on" address=:9100\
Jun 06 06:33:25 vagrant node_exporter[783]: level=info ts=2021-06-06T06:33:25.829Z caller=tls_config.go:191 msg="TLS is disabled." http2=false

2.\
--collector.uname          Enable the uname collector (default: enabled).    Exposes system information as provided by the uname system call.\
--collector.time           Enable the time collector (default: enabled).    Exposes the current system time.\
--collector.cpu.info       Enables metric cpu_info\
--collector.cpu            Enable the cpu collector (default: enabled).        Exposes CPU statistics\
--collector.diskstats      Enable the diskstats collector (default: enabled).    Exposes disk I/O statistics.\
--collector.filesystem     Enable the filesystem collector (default: enabled).    Exposes filesystem statistics, such as disk space used.\
--collector.loadavg        Enable the loadavg collector (default: enabled).    Exposes load average.\
--collector.meminfo        Enable the meminfo collector (default: enabled).    Exposes memory statistics.\
--collector.netclass       Enable the netclass collector (default: enabled).    Exposes network interface info from /sys/class/net/\
--collector.netdev         Enable the netdev collector (default: enabled).    Exposes network interface statistics such as bytes transferred.\
Перечисленные коллекторы включены по умолчанию, поэтому можно просто не менять дефолтные опции. Но если нужно отключить сбор остальных метрик, кроме выбранных:\
--collector.disable-defaults    Set all collectors to disabled by default.

3.\
cpu - процентная загрузка CPU суммарно (от 0 до 100%)\
load - загрузка CPU в единицах CPU, усредненнная за 1, 5 и 15 минут\
disk - суммарная загрузка I/O KiB/s\
ram - загрузка памяти MiB free/used/cached/buffers\
swap - MiB free/used\
network - kilobits/s received/sent суммарно/IP/IPv6\
processes - системные и суммарно\
и другие\
а также разбивки по контекстам, пользователям, состояниям, типам операций, файловым системам, сетевым протоколам, интерфейсам и пр.

4.\
Да, по наличию строки "Hypervisor detected:" :\
$ dmesg | grep "Hypervisor detected"\
[    0.000000] Hypervisor detected: KVM

5.\
fs.nr_open = 1048576\
/proc/sys/fs/nr_open содержит значение параметра ядра, ограничивающее максимальное количество файлов, которое может быть открыто процессом.\
Фактически максимальное количество файлов ограничивается лимитом RLIMIT_NOFILE (который не может превышать fs.nr_open), который можно установить в /etc/security/limits.conf:\
{\<user>|@\<group>}    {hard|soft|-}    nofile    10000\
А также временно установить в текущей сессии (на значение не выше текущего hard limit):\
ulimit -[HS]n 10000

6.\
\# unshare -f --pid --mount-proc sleep 111111 &\
\# ps aux | grep sleep\
root        1927  0.0  0.0   8080   596 pts/0    S    19:28   0:00 unshare -f --pid --mount-proc sleep 111111\
root        1928  0.0  0.0   8076   596 pts/0    S    19:28   0:00 sleep 111111\
\# nsenter --target 1928 --pid --mount\
/# ps aux\
USER         PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND\
root           1  0.0  0.0   8076   596 pts/0    S    19:28   0:00 sleep 111111\
root           2  0.0  0.4   9836  4084 pts/0    S    19:29   0:00 -bash\
root          11  0.0  0.3  11492  3260 pts/0    R+   19:29   0:00 ps aux\
/# lsns\
        NS TYPE   NPROCS PID USER COMMAND\
4026531835 cgroup      3   1 root sleep 111111\
4026531837 user        3   1 root sleep 111111\
4026531838 uts         3   1 root sleep 111111\
4026531839 ipc         3   1 root sleep 111111\
4026531992 net         3   1 root sleep 111111\
4026532188 mnt         3   1 root sleep 111111\
4026532189 pid         3   1 root sleep 111111\
/# exit\
\# lsns\
        NS TYPE   NPROCS   PID USER            COMMAND\
4026531835 cgroup    113     1 root            /sbin/init\
4026531836 pid       112     1 root            /sbin/init\
4026531837 user      113     1 root            /sbin/init\
4026531838 uts       111     1 root            /sbin/init\
4026531839 ipc       113     1 root            /sbin/init\
4026531840 mnt        99     1 root            /sbin/init\
4026531860 mnt         1    21 root            kdevtmpfs\
4026531992 net       113     1 root            /sbin/init\
4026532162 mnt         1   396 root            /lib/systemd/systemd-udevd\
4026532163 uts         1   396 root            /lib/systemd/systemd-udevd\
4026532164 mnt         1   405 systemd-network /lib/systemd/systemd-networkd\
4026532183 mnt         1   561 systemd-resolve /lib/systemd/systemd-resolved\
4026532184 mnt         5   787 netdata         /usr/sbin/netdata -D\
4026532186 mnt         1  1712 root            /usr/libexec/fwupd/fwupd\
4026532188 mnt         2  1927 root            unshare -f --pid --mount-proc sleep 111111\
4026532189 pid         1  1928 root            sleep 111111\
4026532247 uts         1   617 root            /lib/systemd/systemd-logind\
4026532249 mnt         1   608 root            /usr/sbin/irqbalance --foreground\
4026532250 mnt         1   617 root            /lib/systemd/systemd-logind

7.\
:(){ :|:& };:\
Создание функции, которая вызывает два экземпляра себя в фоне, + ее вызов.

] cgroup: fork rejected by pids controller in /user.slice/user-1000.slice/session-4.scope\
] cgroup: fork rejected by pids controller in /user.slice/user-1000.slice/session-23.scope

Ограничение максимального количества процессов в cgroup user-1000.slice:\
$ cat /sys/fs/cgroup/pids/user.slice/user-1000.slice/pids.max\
2359\
$ systemctl status user-1000.slice\
Tasks: 15 (limit: 2359)\
Можно настроить в файлах конфигурации юнитов systemd в TasksMax:\
$ systemctl cat user-1000.slice\
\# /usr/lib/systemd/system/user-.slice.d/10-defaults.conf\
...\
[Slice]\
TasksMax=33%\
(TasksMax= и DefaultTasksMax= могут быть заданы как число или процент от меньшего из /proc/sys/kernel/pid_max, /proc/sys/kernel/threads-max, /sys/fs/cgroup/pids.max)

Также есть ограничение максимального количества процессов на пользователя RLIMIT_NPROC:\
$ ulimit -Su\
3575\
Если поставить его ниже pids.max, поведение системы при запуске функции будет аналогичным, но без сообщения 'cgroup: fork rejected by pids controller' в dmesg:\
$ ulimit -Su\
1234



## ДЗ 3.3
1.\
stat("/tmp", {st_mode=S_IFDIR|S_ISVTX|0777, st_size=4096, ...}) = 0\
chdir("/tmp")

2.\
/usr/share/misc/magic.mgc -> ../../lib/file/magic.mgc

3.\
ls -l /proc/\<pid>/fd\
Для дескпритора, связанного с проблемным файлом:\
\> /proc/\<pid>/fd/\<number>

4.\
Зомби процессы не занимают CPU, RAM, IO, занимают только строчку в таблице процессов.

5.\
PID    COMM               FD ERR PATH\
1      systemd            12   0 /proc/400/cgroup\
773    vminfo              4   0 /var/run/utmp\
592    dbus-daemon        -1   2 /usr/local/share/dbus-1/system-services\
592    dbus-daemon        18   0 /usr/share/dbus-1/system-services\
592    dbus-daemon        -1   2 /lib/dbus-1/system-services\
592    dbus-daemon        18   0 /var/lib/snapd/dbus-1/system-services/

6.\
uname({sysname="Linux", nodename="vagrant", ...}) = 0\
/proc/sys/kernel/{ostype,hostname,osrelease,version,domainname}\
       Part of the utsname information is also accessible via\
       /proc/sys/kernel/{ostype, hostname, osrelease, version,\
       domainname}.

7.\
Команды через ; выполняются последовательно как отдельные команды. Через && - последующая команда выполняется при успешном коде завершения первой.\
&& можно использовать с set -e. При использовании set -e шелл будет закрыт сразу после возврата какой-нибудь командой кода завершения с ошибкой (>0). Но в последовательностях команд с && и || будет учитываться статус только последней команды.

8.\
set -euxo pipefail\
Опции -eo pipefail прерывают выполнение скрипта в случае неуспешного кода завершения какой-либо команды, включая команды в пайплайнах, но исключая команды составных команд, следующих за while, until, if, or elif, и непоследние команды в последовательностях && и ||. Опция -u прерывает выполнение скрипта при попытке обращения к неустановленным переменным (но при необходимости можно ${a:-}). Это опции защищают от продолжения выполнения скрипта после непредусмотренной ошибки.\
-x - выводит каждую команду перед выполнением, но после всех подстановок, что позволяет определить место ошибки.

9.\
ps -axh -o stat | grep ^S | wc -l\
S - 59\
I - 47\
R - 1\
Z - 1

D    uninterruptible sleep (usually IO)\
I    Idle kernel thread\
R    running or runnable (on run queue)\
S    interruptible sleep (waiting for an event to complete)\
T    stopped by job control signal\
t    stopped by debugger during the tracing\
W    paging (not valid since the 2.6.xx kernel)\
X    dead (should never be seen)\
Z    defunct ("zombie") process, terminated but not reaped by its parent

<    high-priority (not nice to other users)\
N    low-priority (nice to other users)\
L    has pages locked into memory (for real-time and custom IO)\
s    is a session leader\
l    is multi-threaded (using CLONE_THREAD, like NPTL pthreads do)\
\+    is in the foreground process group



## ДЗ 3.2
1.\
$ type -t cd\
builtin

cd сменяет текущую директирию в shell-сессии. Если бы она не была встроенного типа, пришлось бы дополнительно организовать обмен данными между cd и bash и смену директории в bash на основе полученных данных.

2.\
grep -с <some_string> <some_file>

3.\
systemd\
(/sbin/init -> /lib/systemd/systemd)

4.\
ls something 2>/dev/pts/1

5.\
$ cat \<log >newfile

6.\
Итак, я нахожусь в стороннем PTY(/dev/pts/1) и хочу вывести данные в TTY, который открыт в графическом режиме (/dev/pts/0).\
echo 12345456 > /dev/pts/0\
Или я нахожусть в графическом режиме в TTY (/dev/pts/0) и хочу получить данные из стороннего PTY(/dev/pts/1).\
cat /dev/pts/1\
При этом часть данных попадает в /dev/pts/0, а часть остается в /dev/pts/1\
cat /dev/pts/1 | tee /dev/pts/1\
Дает более интересный эффект - данные дублируются и там, и там, но pts/1 не работает адекватно\
Или что имелось в виду?

7.\
bash 5>&1\
Запускает баш с перенаправлением данных из файлового дескриптора 5 в stdout, а именно в /dev/pts/1.

echo netology > /proc/$$/fd/5\
Отправим данных в fd 5 и они выведутся в /dev/pts/1.

8.\
ls log kdsksdklog 3>&2 2>&1 1>&3 | grep --color log\
log\
ls: cannot access 'kdsksdklog': No such file or directory

9.\
/proc/$$/environ содержит переменные окружения, установленные на момент старта процесса. Данные в файле не обновляются при последующих изменениях переменных.\
cat /proc/$$/environ | tr '\000' '\n'

Аналогичные, но обновляемые, актуальные данные можно получить:\
env\
printenv\
set

10.\
/proc/\<PID\>/cmdline - полная командная строка запуска процесса или, для зомби процессов, пусто\
/proc/\<PID\>/exe - символическая ссылка на исполняемый файл процесса

11.\
SSE4.2

12.\
tty выводит имя терминала, связанного с stdin. При выполнении команды через SSH терминал не создается. Stdin имеет вид: /proc/2939/fd/0 -> pipe:[84091]

13.\
\# echo 0 > /proc/sys/kernel/yama/ptrace_scope

$ nc -l 3333\
^Z\
[1]+  Stopped                 nc -l 3333

vagrant     2454    1669  0 19:01 pts/1    00:00:00 nc -l 3333

$ disown 2454

vagrant     2454    1669  0 19:01 pts/1    00:00:00 nc -l 3333

(screen) $ reptyr 2454

vagrant     2454    1669  0 19:01 pts/0    00:00:00 nc -l 3333\
vagrant     2468    2256  0 19:04 pts/2    00:00:00 reptyr 2454

14.\
sudo echo string > /root/new_file\
echo string | sudo tee /root/new_file\
tee выводит stdin в файл и дублирует в stdout\
При использовании tee файл /root/new_file открывается с правами tee, которая запущена с sudo - с правами root.


## ДЗ 3.1

5.
vagrant_default_xxxxxxxxxxxxx_xxxxx\
1024 MB RAM\
2 CPU cores 100% +Enable PAE/NX -Enable Nested VT-x/AMD-V\
1 dynamic SATA vmdk 64 GB\
NAT network, port 22 to 127.0.0.1:2222\
1 display 4 MB\
No audio, USB, COM

6.
config.vm.provider "virtualbox" do |vb|\
  vb.memory = 2048\
  vb.cpus = 3\
end

8.
1) переменная HISTSIZE\
history-size (unset)\
       Set  the maximum number of history entries saved in the history list.  If set to zero, any existing history entries are deleted and no new entries are saved.  If set to a value less
       than zero, the number of history entries is not limited.  By default, the number of history entries is set to the value of the HISTSIZE shell variable.  If an attempt is made to set
       history-size to a non-numeric value, the maximum number of history entries will be set to 500.
2) ignoreboth в составе переменной HISTCONTROL приводит к несохранению в history команд, начинающихся с пробела, и команд, совпадающих с последней строкой history

9.
1) Для группировки команд и выполнения их в текущем контексте, в том числе для формирования тела функций:\
	{ list; }\
       list  is  simply  executed in the current shell environment.  list must be terminated with a newline or semicolon.  This is known as a group com‐
       mand.  The return status is the exit status of list.  Note that unlike the metacharacters ( and ), { and } are  reserved  words  and  must  occur
       where a reserved word is permitted to be recognized.  Since they do not cause a word break, they must be separated from list by whitespace or an‐
       other shell metacharacter.

2) brace expansion для генерации строк из перечислений и дипазонов\
	Brace Expansion\
		Brace expansion is a mechanism by which arbitrary strings may be generated. This mechanism is similar to pathname expansion, but the filenames generated need not exist. Patterns to be brace expanded take the form of an optional preamble, followed by either a series of comma-separated strings or a sequence expression between a pair of braces, followed by an optional postscript. The preamble is prefixed to each string contained within the braces, and the postscript is then appended to each resulting string, expanding left to right.
		Brace expansions may be nested. The results of each expanded string are not sorted; left to right order is preserved. For example, a{d,c,b}e expands into 'ade ace abe'.
		A sequence expression takes the form {x..y[..incr]}, where x and y are either integers or single characters, and incr, an optional increment, is an integer. When integers are supplied, the expression expands to each number between x and y, inclusive. Supplied integers may be prefixed with 0 to force each term to have the same width. When either x or y begins with a zero, the shell attempts to force all generated terms to contain the same number of digits, zero-padding where necessary. When characters are supplied, the expression expands to each character lexicographically between x and y, inclusive. Note that both x and y must be of the same type. When the increment is supplied, it is used as the difference between each term. The default increment is 1 or -1 as appropriate. 

3) в рамках конструкции ${} в parameter expansion\
${parameter}\
    The value of parameter is substituted. The braces are required when parameter is a positional parameter with more than one digit, or when parameter is followed by a character which is not to be interpreted as part of its name.

4) 
	Each redirection that may be preceded by a file descriptor number may instead be preceded by a word of the form {varname}. In this case, for each redirection operator except >&- and <&-, the shell will allocate a file descriptor greater than 10 and assign it to varname. If >&- or <&- is preceded by {varname}, the value of varname defines the file descriptor to close.

5) Управление форматом строки приглашения bash\
    \D{format} \
		the format is passed to strftime(3) and the result is inserted into the prompt string; an empty format results in a locale-specific time representation. The braces are required 

10.
$ touch f{01..100000}\
$ touch {1..300000}\
-bash: /usr/bin/touch: Argument list too long

$ getconf ARG_MAX\
2097152\
$ echo {1..300000} | wc -c\
1988895\
почему?..

11.\
       [[ expression ]]\
              Return  a status of 0 or 1 depending on the evaluation of the conditional expression expression.  Expressions are composed of the primaries described below under CONDITIONAL EXPRES‐
              SIONS.  Word splitting and pathname expansion are not performed on the words between the [[ and ]]; tilde expansion, parameter and variable expansion, arithmetic expansion,  command
              substitution, process substitution, and quote removal are performed.  Conditional operators such as -f must be unquoted to be recognized as primaries.
			  
[[ -d /tmp ]] - проверяет, что существует директория /tmp

12.
$ echo $PATH\
/tmp/new_path_directory:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin\
$ type -a bash\
bash is /tmp/new_path_directory/bash\
bash is /usr/bin/bash\
bash is /bin/bash

13.
at - выполняет задание в явно указанное время\
batch - выполняет задание, когда загрузка CPU падает ниже порогового значения
