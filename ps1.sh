#!/bin/bash

# Получяем Uid текущего пользователя
get_uid()
{
  cat /proc/$pc/status | grep Uid | awk '{print $2}'
}

# username из Uid
get_username()
{
  cat /etc/passwd | grep "x:$(get_uid)" | awk -F":" '{print $1}'
}

# Логин пользователя
get_env_user()
{
  env | awk -F"=" '/LOGNAME/{print $2}'
}

# Получение строки запуска
get_cmd()
{
  cat /proc/$pc/cmdline | strings -1  |  tr -d '\n' | tr -d ' '| head -c 100
}

# Получение состояния процесса
get_stat()
{
  cat /proc/$pc/status | awk '/State/{print $2}'
}

# Получение потребления VMRSS
get_vmrss()
{
  cat /proc/$pc/status | awk '/VmRSS/{print $2}'
}

# Выводим процессы для текущего пользователя
get_uuser()
{
  fl="%-20s%-10s%-10s%-10s%-100s\n"
  printf "$fl" USER PID STAT VMRSS COMMAND
  
  # Получаем имена каталогов из /proc у которых только цифры, т.к. это имена запущенных процессов
  for pc in `ls /proc | grep "^[0-9]" | sort -n`
  do
    if [ -f /proc/$pc/status ]
        then
        if [[ $(get_env_user) == $(get_username) ]]
        then
        PID=$pc
        # Перехват сигнала CTRL ^C
        trap "echo 'Продолжить выполнение?' && read -p 'Нажмите - ENTER:'" SIGINT 
        printf "$fl" $(get_username) $PID $(get_stat) $(get_vmrss) $(get_cmd)
        fi
    fi
  done
  # Обработка сигнала при закрытии скрипта
  trap "echo Успешное завершение работы скрипта!!!" EXIT
}

get_param()
{
  fl="%-20s%-10s%-10s%-10s%-100s\n"
  printf "$fl" USER PID STAT VMRSS COMMAND

  # Получаем имена каталогов из /proc у которых только цифры, т.к. это имена запущенных процессов
  for pc in `ls /proc | grep "^[0-9]" | sort -n`
  do
    if [ -f /proc/$pc/status ]
        then
        getcmd=`cat /proc/$pc/cmdline | strings -1`
      if [ "$getcmd" != '' ]
        then
           getcmd=`cat /proc/$pc/cmdline | strings -1  |  tr -d '\n' | tr -d ' '| head -c 100`
            PID=$pc
           # Выводим результат
           printf "$fl" $(get_username) $PID $(get_stat) $(get_vmrss) $getcmd
           else
           getcmd="[`awk '/Name/{print $2}' /proc/$pc/status`]"
            PID=$pc
            # Перехват сигнала CTRL ^C
            trap "echo 'Продолжить выполнение?' && read -p 'Нажмите - ENTER:'" SIGINT 
           printf "$fl" $(get_username) $PID $(get_stat) $(get_vmrss) $getcmd
      fi
    fi
  done 
  trap "echo Успешное завершение работы скрипта!!!" EXIT
}

get_param()
{
  # Форматируем вывод текста на экран
  fl="%-20s%-10s%-10s%-10s%-100s\n"
  printf "$fl" USER PID STAT VMRSS COMMAND

  # Получаем имена каталогов из /proc у которых только цифры, т.к. это имена запущенных процессов
  for pc in `ls /proc | grep "^[0-9]" | sort -n`
  do
    if [ -f /proc/$pc/status ]
    then
      PID=$pc
      # Перехват сигнала CTRL ^C
      trap "echo 'Продолжить выполнение?' && read -p 'Нажмите - ENTER:'" SIGINT
      printf "$fl" $(get_username) $PID $(get_stat) $(get_vmrss) $(get_cmd)
    fi
  done
  trap "echo Успешное завершение работы скрипта!!!" EXIT
}

# Вывод в соответствии с параметрами
case "$1" in
  a) get_uuser;;
  ax) get_param;;
  *) echo "Не допустимая комманда.\nПример использования: bash ./ps.sh (a/ax)";;
esac
