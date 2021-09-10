# Coordenadas límite de México.
mlon1="-118.390"
mlon2="-86.660"
mlat1="14.566"
mlat2="32.737"

# Coordenadas límite de la Cuenca
# del Valle de México.
clon1="-99.749"
clon2="-98.194"
clat1="19.049"
clat2="20.776"

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