# Descarga toda la información de ERA5 para una variable.

# Stop at first error.
set -e

# Default options for variables.
DATA="levels"
VAR="u"
LEVEL="500"

echo $LEVEL

# Read arguments.
while getopts d:v:l: flag
do
    case "${flag}" in
        d) DATA=${OPTARG};;
        v) VAR=${OPTARG};;
        l) LEVEL=${OPTARG};;
    esac
done

echo $LEVEL

# Cambiar al folder local!!!
CONDA_SOURCE="/opt/homebrew/Caskroom/miniforge/base"
source "$CONDA_SOURCE/etc/profile.d/conda.sh"
# Cambiar por el nombre del environment local!!!
conda activate gv

echo ""
echo "Beginning ERA5 download request"
echo ""
echo "Variable: "$VAR

YEARS=( 1981 1990 2000 2010 2022 )
# Pressure levels.
if [ $DATA == "levels" ]
then
    echo "Dataset : Pressure levels"
    echo "Level   : "$LEVEL
    echo ""
    echo ""

    # Download all years in four batches.
    for i in 0 1 2 3
    do
    j=$((i + 1))
    echo "Downloading" $VAR $LEVEL ${YEARS[i]} ${YEARS[j]} "..."
    echo ""
    python ERA5_levels_request.py $VAR $LEVEL ${YEARS[i]} ${YEARS[j]}
    echo ""
    echo ""
    done

    echo "Processing files..."
    echo ""

    DIR='../data/ERA5/'
    DIR_TEMP=$DIR$VAR'/'
    FILES=$DIR_TEMP'*.grib'
    IN=$DIR_TEMP'/mexico_'$VAR'_'$LEVEL'_hourly.grib'
    MID=$DIR_TEMP'mexico_'$VAR'_'$LEVEL'_hourly_leap.grib'
    OUT_1=$DIR'mexico_'$VAR'_'$LEVEL'_daily.grib'
    OUT_2=$DIR'mexico_'$VAR'_'$LEVEL'_daily_mean.grib'

    # Merge all years and convert from hourly to daily.
    cdo mergetime $FILES $IN
    cdo  del29feb $IN    $MID
    cdo   daymean $MID   $OUT_1
    cdo  ydaymean $MID   $OUT_2
    rm -r $DIR_TEMP

    echo "All files downloaded and processed succesfully."
    echo ""

# Single levels.
elif [ $DATA == "single" ]
then
    echo "Dataset : Single level"
    echo ""
    echo ""

    # Download all years in four batches.
    for i in 0 1 2 3
    do
    j=$((i + 1))
    echo "Downloading" $VAR ${YEARS[i]} ${YEARS[j]}  "..."
    echo ""
    python ERA5_single_request.py $VAR ${YEARS[i]} ${YEARS[j]}
    echo ""
    echo ""
    done

    echo "Processing files..."
    echo ""

    DIR='../data/ERA5/'
    DIR_TEMP=$DIR$VAR'/'
    FILES=$DIR_TEMP'*.grib'
    IN=$DIR_TEMP'/mexico_'$VAR'_hourly.grib'
    MID=$DIR_TEMP'mexico_'$VAR'_hourly_leap.grib'
    OUT_1=$DIR'mexico_'$VAR'_daily.grib'
    OUT_2=$DIR'mexico_'$VAR'_daily_mean.grib'

    # Merge all years and convert from hourly to daily.
    cdo mergetime $FILES $IN
    cdo  del29feb $IN    $MID
    cdo   daymean $MID   $OUT_1
    cdo  ydaymean $MID   $OUT_2
    rm -r $DIR_TEMP

    echo ""
    echo "All files downloaded and processed succesfully."
    echo ""

# Incorrect dataset.
else
    echo "The selected Dataset doesn't exist, choose either 'levels' or 'single'."
    echo ""
fi