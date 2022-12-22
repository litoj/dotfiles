#!/usr/bin/bash
ftest=""
for f in *.txt; do
	IFS=— data=($(cat $f))
	fail=""
	declare -i i=1
	rm ${f/.txt/.err} 2> /dev/null
	if [[ $1 == compile ]]; then
		[[ -f ${f/.txt/.out} ]] && rm ${f/.txt/.out}
		g++ -Wall -pedantic "${f/.txt/.c}" -o "${f/.txt/.out}"
		(($?)) && ftest+="${f/.txt/.c}" && continue
	fi
	f=./${f/.txt/.out}
	for t in "${data[@]}"; do
		if [[ $t ]]; then
			IFS=\\ t=($t)
			t[0]=${t[0]#[
 ]}
			res="$($f <<< "${t[0]%[
 ]}")
"
			echo "$res"
			[[ ${t[1]} && $res != ${t[1]} ]] && fail+="$i " && printf "$i\n%svs ref:\n%s" "$res" "${t[1]}" >> ${f/.txt/.err}
			i+=1
		fi
	done
	[[ $fail ]] && ftest+="${f/.txt/} " && echo "$fail"
done
if [[ $ftest ]]; then
	echo "ERR in: $ftest"
	exit 1
else
	exit 0
fi
