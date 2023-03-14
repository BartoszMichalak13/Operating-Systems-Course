#!/bin/bash

pid_array=`ls /proc | grep -E '^[0-9]+$'`

cat /dev/null > .data.akiso
printf "%s;%s;%s;%s;%s;%s;%s;%s;%s;\n" "PID" "COMM" "PPID" "STATE" "TTY" "RSS" "PGID" "SID" "OPEN_FILES" >> .data.akiso 
for pid in $pid_array
do
	if [ -r /proc/$pid/stat ]
	then
		stat_array=( `cat /proc/$pid/stat` )
		ppid=${stat_array[3]}
		comm=${stat_array[1]}
		state=${stat_array[2]}
		tty_nr=${stat_array[6]}
		rss=${stat_array[23]}
		pgid=${stat_array[4]}
		sid=${stat_array[5]}
		open_files=( `lsof -p $pid | wc -l` )
		printf "%d;%s;%d;%s;%d;%d;%d;%d;%d\n" $pid $comm $ppid $state $tty_nr $rss $pgid $sid $((open_files - 1)) >> .data.akiso	
	fi
done
clear
column .data.akiso -t -s ";"

