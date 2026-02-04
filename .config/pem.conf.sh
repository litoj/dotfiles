executeConfig=(
	--after '2024-07-27'
)

categorizeConfig=(
	--dst '/tmp/categorized'
)

fix35mmFl() {
	bc <<<"1.5*$(getExif "$1" '$FocalLength')"
}

declare -gA editPresets=(
	['fixManualFl']=editFixManualFl
)
editFixManualFl=(
	-t FocalLength -v ''
	-t FocalLengthIn35mmFormat -v '$fix35mmFl$'
	-t LensInfo -v '$FocalLength $FocalLength undef undef'
	-t MinFocalLength -v '$FocalLength'
	-t MaxFocalLength -v '$FocalLength'
)

# NOTES:
# for architecture just use 9mm and correct lines in post
# Used FocalLengths: 12, 16-17, 22-30, 33-45, 55-70, 90, 100, 110, 135-200
# Ratings: 0=just cause, 1=has an idea, 2=good composition or conditions, lacking edit or other,
#          3=solid comp + edit + conditions, 4=very good comp + excellent edit, 5=perfect
