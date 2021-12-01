# Obtiene los datos diarios de CHIRPS y los recorta al
# límite de México y de la Cuenca del Valle de México.

# Stop at first error.
set -e

# Coordenadas límite de México.
mlon1="-118.75"
mlon2="-86.25"
mlat1="14.25"
mlat2="32.75"

# Coordenadas límite de la Cuenca
# del Valle de México.
clon1="-99.75"
clon2="-97.25"
clat1="18.75"
clat2="21.25"

# Rutas de datos y resultados
path_d="data/CPC_Pre"
mpath_r="results/CPC_Pre/Mexico"
cpath_r="results/CPC_Pre/cuenca_valle_mexico"

mkdir -p $path_d
mkdir -p $mpath_r
mkdir -p $cpath_r

# Descarga todos los archivos de CPC Daily.
#mkdir -p path_d
#cd path_d
#wget -r -np -nH --cut-dirs=3 -R index.html --level=0 -e robots=off https://psl.noaa.gov/thredds/fileServer/Datasets/cpc_global_precip/
#mv netcdf/p05/*.nc .
#rm -r netcdf

# Se hace un ciclo en todos los archivos.
for filename in $path_d/*.nc; do
    echo "Procesando ${filename##*/}"
    # Evita errores en la wildcard.
    shopt -s nullglob
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

echo "Uniendo archivos anuales para la cuenca"
cd $cpath_r
#mkdir temp
#mv cuenca_valle_mexico_precip.2021.nc ./temp
# Une todos los archivos salvo el último año.
cdo mergetime *.nc cuenca_valle_mexico_precip.nc
#mv temp/cuenca_valle_mexico_precip.2021.nc .
#rm -r temp
cd ../../../
echo "Archivos anuales para la cuenca unidos"
echo ""

echo "Uniendo archivos anuales para Mexico"
cd $mpath_r
#mkdir temp
#mv mexico_precip.2021.nc ./temp
# Une todos los archivos salvo el último año.
cdo mergetime *.nc mexico_precip.nc
#mv temp/mexico_precip.2021.nc .
#rm -r temp
echo "Archivos anuales apra Mexico unidos"
echo ""
