INI="1979"
FIN="1990"
VAR="v"
LEVEL="500"
REGION="mexico"

IN='../data/ERA5/'$REGION'_'$VAR'_'$LEVEL'_'$INI'_'$FIN'_hourly.grib'
MID='../data/ERA5/'$REGION'_'$VAR'_'$LEVEL'_'$INI'_'$FIN'_hourly_leap.grib'
OUT_1='../data/ERA5/'$REGION'_'$VAR'_'$LEVEL'_'$INI'_'$FIN'_daily.grib'
OUT_2='../data/ERA5/'$REGION'_'$VAR'_'$LEVEL'_'$INI'_'$FIN'_daily_mean.grib'

cdo del29feb $IN  $MID
cdo  daymean $MID $OUT_1
cdo ydaymean $MID $OUT_2

rm $MID