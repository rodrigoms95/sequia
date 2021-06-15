# Instalación de FLEXPART

La configuración es específica para el usuario llamado `username`. Copiar `flex_install`, `.cdsapirc`, y `.emcwfapirc` a la carpeta `$HOME`, que es `/home/username/`

## Comando para instalar FLEXPART en una distribución nueva de Ubuntu/Debian
```shell
sudo -H bash ~/flex_install/flex_install.sh -n username -c miniconda -w
```

## Comando tipo para correr flex_extract
```shell
sudo $CONDA_FP $FLEX_SUBMIT --controlfile=$CONTROL_FILE --start_date=$START_DATE --public=$PUBLIC --inputdir=$FLEX_INPUT --outputdir=$FLEX_OUTPUT
```
