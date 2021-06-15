# Configuración de Linux

La configuración es específica para el usuario llamado `username`.

## Crear ambientes en conda para geoviews y climate-indices
```shell
sudo -H bash ~/flex_install/conda_setup.sh -n username -c miniconda
```

## Instalar Jekyll
```shell
sudo -H bash ~/flex_install/jekyll_install.sh
```

## Recuperar explorer.exe en WSL
```shell
export PATH="/mnt/c/WINDOWS/system32:/mnt/c/WINDOWS:$PATH"
```

## Otros paquetes importantes
```shell
sudo apt-get -y -qq install vim dos2unix
```
