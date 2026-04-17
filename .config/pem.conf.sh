executeConfig=(
	--after '2024-07-27'
)

categorizeConfig=(
	--dst '/tmp/categorized'
)

fix35mmFl() {
	bc < <(getExif '$FocalLength*1.5')
}

editSetFl=(
	-t FocalLength -v ''
	-t LensInfo -v '$FocalLength $FocalLength undef undef'
	-t FocalLengthIn35mmFormat -v '$fix35mmFl$'
	-t MinFocalLength -v '$FocalLength'
	-t MaxFocalLength -v '$FocalLength'
)

editSetFl500=(
	-t FocalLength -v 500
	-t FNumber -v 8
	-t LensInfo -v '$FocalLength $FocalLength 8 8'
	"${editSetFl[@]:8}"
)

editSetFl35=(
	-t FocalLength -v 35
	-t FNumber -v 1.4
	-t LensInfo -v '$FocalLength $FocalLength 1.4 16'
	"${editSetFl[@]:8}"
)

# NOTE: for full detail on vanames use: exiftool -a -s -G1
# to specify a group use exiftool -<group>:<tag> (Image=IFD0, Photo=ExifIFD, Fujifilm=Fujifilm)
declare -gA editPresets=(
	['FL=?']=editSetFl
	['FL=500']=editSetFl500
	['FL=35']=editSetFl35
)

# TODO: more 3D photo attempts
# NOTES:
# for architecture just use 9mm and correct lines in post
# Used FocalLengths: 12, 16-17, 22-30, 33-45, 55-70, 90-180
# Ratings: 0=just cause, 1=has an idea, 2=good composition or conditions, lacking edit or other,
#          3=solid comp + edit + conditions, 4=very good comp + excellent edit, 5=perfect
