executeConfig=(
	--after '2024-02-27'
)

categorizeConfig=(
	--dst '/tmp/categorized'
)

fix35mmFL() {
	bc <<<"1.5*$(getExif "$1" '$FocalLength')"
}

declare -gA editPresets=(
	['fixManualFL']=editFixManualFL
)
editFixManualFL=(
	-t FocalLength -v ''
	-t FocalLengthIn35mmFormat -v '$fix35mmFL$'
	-t LensInfo -v '$FocalLength $FocalLength undef undef'
	-t MinFocalLength -v '$FocalLength'
	-t MaxFocalLength -v '$FocalLength'
)
