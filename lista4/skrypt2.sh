#!/bin/bash

#CPU_USAGE_COUNTER
function CUC()
{
	value=`cat /proc/stat | grep $1 -w | awk '{print ($2+$3+$4+$5+$6+$7+$8+$9+$10)}'`
	echo $value
}

#IDLE_CPU
function IC()
{
	value=`cat /proc/stat | grep $1 -w | awk '{print ($5)}'`
	echo $value
}


function KiloMega()
{
	if [ $1 -gt 1048576 ]
	then
		value="$(($1/1048576))"Mb
	elif [ $1 -gt 1024 ]
	then 
		value="$(($1/1024))"Kb
	else
		value="$1"bits
	fi
	echo $value
}

firstup1=($(awk 'NR == 4 {print $10}' /proc/net/dev))
firstup2=($(awk 'NR == 3 {print $10}' /proc/net/dev))
firstdown1=($(awk 'NR == 4 {print $2}' /proc/net/dev))
firstdown2=($(awk 'NR == 3 {print $2}' /proc/net/dev))
firstdown=$((firstdown1+firstdown2))
firstup=$((firstup1+firstup2))
prevup=$firstup
prevdown=$firstdown
i=0

#visual up&down
declare -a arrdown
declare -a arrup
for i in {1..6}
do
	arrdown+=(0)
	arrup+=(0)
done

begining0=$(CUC cpu0)
begining1=$(CUC cpu1)
begining2=$(CUC cpu2)
begining3=$(CUC cpu3)

prev_cpu0=$begining0
prev_cpu1=$begining1
prev_cpu2=$begining2
prev_cpu3=$begining3

begining_idle0=$(IC cpu0)
begining_idle1=$(IC cpu1)
begining_idle2=$(IC cpu2)
begining_idle3=$(IC cpu3)

prev_idle_cpu0=$begining_idle0
prev_idle_cpu1=$begining_idle1
prev_idle_cpu2=$begining_idle2
prev_idle_cpu3=$begining_idle3
while true 
do
	#CPU
	
	currentcpu0=$(($(CUC cpu0)-prev_cpu0))	
	currentcpu1=$(($(CUC cpu1)-prev_cpu1))	
	currentcpu2=$(($(CUC cpu2)-prev_cpu2))	
	currentcpu3=$(($(CUC cpu3)-prev_cpu3))

	prev_cpu0=$(CUC cpu0)	
	prev_cpu1=$(CUC cpu1)	
	prev_cpu2=$(CUC cpu2)	
	prev_cpu3=$(CUC cpu3)

	currentidle_cpu0=$(($(IC cpu0)-prev_idle_cpu0))	
	currentidle_cpu1=$(($(IC cpu1)-prev_idle_cpu1))	
	currentidle_cpu2=$(($(IC cpu2)-prev_idle_cpu2))	
	currentidle_cpu3=$(($(IC cpu3)-prev_idle_cpu3))	
	
	prev_idle_cpu0=$(IC cpu0)	
	prev_idle_cpu1=$(IC cpu1)	
	prev_idle_cpu2=$(IC cpu2)	
	prev_idle_cpu3=$(IC cpu3)

	usage_cpu0=$((100-currentidle_cpu0*100/currentcpu0))	
	usage_cpu1=$((100-currentidle_cpu1*100/currentcpu1))	
	usage_cpu2=$((100-currentidle_cpu2*100/currentcpu2))	
	usage_cpu3=$((100-currentidle_cpu3*100/currentcpu3))	

	MHz_cpu0=`cat /proc/cpuinfo | grep "MHz" | awk 'NR == 1 {print $4}'`
	MHz_cpu1=`cat /proc/cpuinfo | grep "MHz" | awk 'NR == 2 {print $4}'`
	MHz_cpu2=`cat /proc/cpuinfo | grep "MHz" | awk 'NR == 3 {print $4}'`
	MHz_cpu3=`cat /proc/cpuinfo | grep "MHz" | awk 'NR == 4 {print $4}'`

	#MEM USAGE
	mem_line1=($(awk 'NR==1 {print;exit}' /proc/meminfo))
	mem_line2=($(awk 'NR==2 {print;exit}' /proc/meminfo))
	total_mem=${mem_line1[1]}
	free_mem=${mem_line2[1]}
	used_mem=$((total_mem - free_mem))

	#BATTERY
	bat_line=($(awk 'NR==12 {print;exit}' /sys/class/power_supply/BAT0/uevent ))
	cap=(${bat_line//=/ })
	bat=${cap[1]}%

	#LOAD
	load=$(awk '{print $1}' /proc/loadavg)

	#TIME ACTIVE
	time=($(awk 'NR == 1 {print $1}' /proc/uptime))
	allseconds=(${time//./ })
	seconds=$((allseconds%60))
	allminutes=$((allseconds/60))
	minutes=$((allminutes%60))
	allhours=$((allminutes/60))
	hours=$((allhours%24))
	alldays=$((allhours/60))

	#NETWORK
	i=$((i+1))
	up1=($(awk 'NR == 4 {print $10}' /proc/net/dev))
	up2=($(awk 'NR == 3 {print $10}' /proc/net/dev))
	down1=($(awk 'NR == 4 {print $2}' /proc/net/dev))
	down2=($(awk 'NR == 3 {print $2}' /proc/net/dev))

	down=$((down1+down2))
	up=$((up1+up2))

	currentup=$((up-prevup))
	currentdown=$((down-prevdown))

	prevup=$up
	prevdown=$down

	upload=$(KiloMega $currentup)
	download=$(KiloMega $currentdown)

	avgup=$(($((up-startup))/$i))
	avgdown=$(($((down-startdown))/$i))
	
	avgupload=$(KiloMega $avgup)
	avgdownload=$(KiloMega $avgdown)
	
	#PRINTING INFO
	clear
	echo up: $upload
	echo down: $download
	echo avgup: $avgupload
	echo avgdown: $avgdownload
	echo load: $load
	echo sekundy: $seconds
	echo minutes: $minutes
	echo godziny: $hours
	echo dni: $alldays
	echo capp: $bat
	echo mem: $used_mem
	
	#PRINTING CPU
	echo usage_cpu0: $usage_cpu0 %
	echo usage_cpu1: $usage_cpu1 %
	echo usage_cpu2: $usage_cpu2 %
	echo usage_cpu3: $usage_cpu3 % 
	echo MHz_cpu0: $MHz_cpu0 MHz
	echo MHz_cpu1: $MHz_cpu1 MHz
	echo MHz_cpu2: $MHz_cpu2 MHz
	echo MHz_cpu3: $MHz_cpu3 MHz	

	#VISUAL DOWN&UP
	arrdown=("${arrdown[@]:1}")
	arrdown+=($((currentdown)))
	arrup=("${arrup[@]:1}")
	arrup+=($((currentup)))
	
	#problem ze zczytywaniem ilosci kolumn/ ustawaiam wartosc stala = 96
	#column_nr=$(tput cols)
	column_nr=96
	col_resized=$(($((column_nr * 3))/4)) 

	maxdown=${arrdown[0]}
	maxup=${arrup[0]}

	for i in "${arrdown[@]}"
	do
		((i > maxdown)) && maxdown=$i
	done
	
	scalerD=$((maxdown / col_resized))
	if [ $scalerD -eq 0 ]
	then
		scalerD=1
	fi

	for i in "${arrup[@]}"
	do
		((i > maxup)) && maxup=$i
	done

	scalerU=$((maxup / col_resized))
	if [ $scalerU -eq 0 ]
	then
		scalerU=1
	fi
	printf '\nDOWNLOAD\n'
	for i in "${arrdown[@]}"
	do
		f_size=$((i/scalerD))
		bar="printf '=%.0s' {0..$f_size}" ;
		eval $bar ;
		printf ' %s' "$(KiloMega $(($i)))"
		printf '\n'
	done
	
	printf '\nUPLOAD\n'
	for i in "${arrup[@]}"
	do
		f_size=$((i/scalerU))
		bar="printf '=%.0s' {0..$f_size}" ;
		eval $bar ;
		printf ' %s' "$(KiloMega $(($i)))"
		printf '\n'
	done		

	sleep 1
done
