# Obtiene los datos diarios de CHIRPS y los recorta al
# límite de México y de la Cuenca del Valle de México.

# Stop at first error.
set -e

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

# Descarga todos los archivos de CHIRPS Daily.
#mkdir -p path_d
#cd path_d
#wget -r -np -nH --cut-dirs=3 -R index.html --level=0 -e robots=off https://data.chc.ucsb.edu/products/CHIRPS-2.0/global_daily/netcdf/p05/
#mv netcdf/p05/*.nc .
#rm -r netcdf

# Se hace un ciclo en todos los archivos.
for filename in $path_d/*.nc; do
    echo "Procesando ${filename##*/}"
    # Evita errores en la wildcard.
    shopt nullglob
    # Escoge el nombre del nuevo archivo.
    # ${filename##*/} quita todo el directorio.
    moutfile="$path_d/mexico_${filename##*/}"
    # Recorta al tamaño de México.
    cdo sellonlatbox,$mlon1,$mlon2,$mlat1,$mlat2 $filename $moutfile
    mv $moutfile $mpath_r
    moutfile="$mpath_r/${moutfile##*/}"
    # Recorta al tamaño de la cuenca del Valle de México.
    coutfile="$path_d/cuenca_valle_mexico_${filename##*/}"
    cdo sellonlatbox,$clon1,$clon2,$clat1,$clat2 $moutfile $coutfile
    mv $coutfile $cpath_r
    echo "${filename##*/} procesado"
    echo ""
done

cd $cpath_r
mkdir temp
mv cuenca_valle_mexico_chirps-v2.0.2021.days_p05.nc ./temp
# Une todos los archivos salvo el último año.
cdo mergetime *.nc cuenca_valle_mexico_chirps-v2.0.days_p05.nc
mv temp/cuenca_valle_mexico_chirps-v2.0.2021.days_p05.nc .
rm -r temp