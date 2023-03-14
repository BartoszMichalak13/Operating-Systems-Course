#!/bin/sh

dir=$1
if [ -d $dir ]
	then 
	if [ -z "$dir" ]
	then
		echo "Nie wybrano folderu"
	else
		if [[ $dir = .* ]]
		then
			cd $dir
		else
			cd ~
			cd $dir
		fi
	
		file_names=$(find . -type f)
		declare -A files
		
		for file in $file_names
		do
			files[$file]=$(sha256sum $file | awk '{print $1}')
		done
		
		declare -A equal_files
		
		for file1 in "${!files[@]}"
		do
			for file2 in "${!files[@]}"
			do
				if [[ $file1 < $file2 ]] && [[ ${files[$file1]} == ${files[$file2]} ]]
				then
					if cmp --silent $file1 $file2
					then
						information=$(printf "[%s]=[%s]" "$(realpath $file1)" "$(realpath $file2)")
						equal_files[$information]=$(($(wc -c $file1 | awk '{print $1}')))
					fi
				fi
			done
		done
		
		for key in "${!equal_files[@]}" 
		do
			echo "$key	 size = ${equal_files[$key]}kb"
		done | sort -k4 -n -r
	fi
fi
