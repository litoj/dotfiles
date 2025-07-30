# dynamically generate presets
declare -gA resizePresets
presets=(
	'i=92/1.jxl'
	'h=90/2.jpg'
	'm=87/2.jxl'
	'q=82/4.jxl'
	's=80/1280.jxl'
	'l=78/800^.jxl'
	'e=90/1.jpg'
)
for preset in "${presets[@]}"; do
	[[ $preset =~ ^(.)=(..)/([^.]*)(\..*)$ ]]
	arr=resize${BASH_REMATCH[1]^}
	resizePresets["$preset"]=$arr
	declare -ga "$arr"
	declare -n arr=$arr
	size=${BASH_REMATCH[3]}
	[[ $size == ? ]] && size=$((100 / size))%

	pred=${BASH_REMATCH[3]%^}
	if ((pred > 1)); then
		((pred < 100)) &&
			((pred = 500 * pred)) || # downsize to max 500px
			((pred = pred * 3 / 2)) # require at least 1.5x the target size
		arr+=(predicate=$pred+)
	fi

	arr+=(
		quality=${BASH_REMATCH[2]}
		size=$size
		dst=${BASH_REMATCH[4]}
	)

	declare +n arr
done
unset arr presets size pred

resizeConfig=(
	predicate=2000+
	quality=90
	dst=.jxl
)

downloadConfig=(metadata=false)
editConfig=(
	rename=true
	metadata=false
	volume=-14LUFS
	volumeTolerance=0.4
	dst=.opus
)
cutConfig=(
	rename=true
)

linkFixConfig=(--resources ~/Music/Songs/)
renameConfig+=(+D)
