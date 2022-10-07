# Descarga toda la información de ERA5 para una variable.

# Stop at first error.
set -e

# Cambiar al folder local!!!
CONDA_SOURCE='/opt/homebrew/Caskroom/miniforge/base'
source $CONDA_SOURCE'/etc/profile.d/conda.sh'
# Cambiar por el nombre del environment local!!!
conda activate gv

D='20'
#VAR_L=( 'u' 'v' 'gp' 'q' )
#VAR_S=( 'sst' 'olr' 'slp' 'vidmf' 'vivfu' 'vivfv' )
#LEVEL=( '925' '700' '500' '200' )
VAR_S=( 'vidmf' )
LEVEL=( '500' )
ANOM=( '.' )
#ANOM=( '.' '_anom.' )

for v in ${VAR_L[@]}
do
    for l in ${LEVEL[@]}
    do
        for a in ${ANOM[@]}
        do

        echo $v'_'$l'_daily'$a'grib'

        IN='../data/ERA5/mexico_'$v'_'$l'_daily'$a'grib'
        OUT='../results/onset/onset_'$v'_'$l'_mean_'$D'_dias'$a'grib'
        #OUT_2='../results/onset/onset_'$v'_'$l'_mean_'$D'_dias'$a'nc'

        cdo runmean,$D $IN $OUT
        #cdo -f nc copy $OUT $OUT_2
        #rm -r $OUT

        echo ""

        done
    done
done

for v in ${VAR_S[@]}
do
    for a in ${ANOM[@]}
    do

    echo $v'_daily'$a'grib'

    IN='../data/ERA5/mexico_'$v'_daily'$a'grib'
    OUT='../results/onset/onset_'$v'_mean_'$D'_dias'$a'grib'
    #OUT_2='../results/onset/onset_'$v'_mean_'$D'_dias'$a'nc'

    cdo runmean,$D $IN $OUT
    #cdo -f nc copy $OUT $OUT_2
    #rm -r $OUT

    echo ""

    done
done