INI="1979"
FIN="1990"
VAR="u"
LEVEL="500"
REGION="mexico"

IN='../data/ERA5/'$REGION'_'$VAR'_'$LEVEL'_'$INI'_'$FIN'_daily.grib'
MID='../data/ERA5/'$REGION'_'$VAR'_'$LEVEL'_'$INI'_'$FIN'_daily_leap.grib'
OUT='../data/ERA5/'$REGION'_'$VAR'_'$LEVEL'_'$INI'_'$FIN'_daily_mean.grib'

cdo del29feb $IN $MID
cdo daymean $MID $OUT
rm $MID