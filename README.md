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
