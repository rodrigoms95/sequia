# Coordenadas límite de México.
mlon1="-118.75"
mlon2="-86.25"
mlat1="14.25"
mlat2="32.75"

# Coordenadas límite de la Cuenca
# del Valle de México.
clon1="-118.75"
clon2="-86.25"
clat1="14.25"
clat2="32.75"

# Rutas de datos y resultados
path_d="data/CHIRPS_global_days_p05"
mpath_r="results/CHIRPS_global_days_p05/Mexico"
cpath_r="results/CHIRPS_global_days_p05/cuenca_valle_mexico"

# Se hace un ciclo en todos los archivos.
for filename in $path_d/*.nc; do
    shopt nullglob
    moutfile="$path_d/mexico_${filename##*/}"
    cdo sellonlatbox,$mlon1,$mlon2,$mlat1,$mlat2 $filename $moutfile
    mv $moutfile $mpath_r
    coutfile="$path_d/cuenca_valle_mexico_${infile##*/}"
    cdo sellonlatbox,$clon1,$clon2,$clat1,$clat2 $filename $coutfile
    mv $moutfile $cpath_r
done