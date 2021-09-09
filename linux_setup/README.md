# Configuración de Linux

La configuración es específica para el usuario llamado `username`.


## Paquetes importantes para  manejar archivos
```shell
sudo apt-get -y -qq install vim dos2unix cdo
```

## Crear ambientes en conda para geoviews, gdal y climate-indices
```shell
sudo -H time bash ~/linux_setup/conda_setup.sh -n username -c miniconda
```

## Instalar Jekyll
```shell
sudo -H time bash ~/linux_setup/jekyll_install.sh
```

## Recuperar explorer.exe . en WSL
```shell
export PATH="/mnt/c/WINDOWS/system32:/mnt/c/WINDOWS:$PATH"
```
