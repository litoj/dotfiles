declare -gA resizePresets
resizePresets['100%i=92/1.jxl']=resizeIdentity
resizePresets['50%h=90/2.jpg']=resizeHalf
resizePresets['25%q=90/4.jxl']=resizeQuarter
resizePresets['s%l=82/1280.jxl']=resizeLow
resizeIdentity=(
	quality=92
	size=100%
	dst=.jxl
)
resizeHalf=(
	predicate=2000+
	quality=90
	size=50%
	dst=.jpg
)
resizeQuarter=(
	predicate=2000+
	quality=90
	size=25%
	dst=.jxl
)
resizeLow=(
	predicate=1800+
	quality=82
	size=1280
	dst=.jxl
)

resizeConfig=(
	predicate=2000+
	quality=92
	dst=.jxl
)

downloadConfig=(metadata=false)
editConfig=(
	--rename
	no-metadata
	volume=-14LUFS
	volumeTolerance=0.4
)

linkFixConfig=(--resources ~/Music/Songs/)
