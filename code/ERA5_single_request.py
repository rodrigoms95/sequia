# Descarga información de una variable de ERA5 Single Levels.

import os
import sys

import cdsapi

# Lista de variables por descargar.
vars = [
    "mean_top_net_long_wave_radiation_flux", 
    "sea_surface_temperature" 
    ]
# Nombre de la base de datos.
dataset = "reanalysis-era5-single-levels"
# Nombre corto de las variables.
svars = [ "olr", "sst" ]

# Escogemos la variable de acuerdo con
# el argumento de la línea de comando.
#   sys.argv[1]: variable a descargar.
#   sys.argv[2]: año inicial.
#   sys.argv[3]: año final (exclusive).
svar = sys.argv[1]
# vars y svars tienen el mismo índice.
var  = vars[ svars.index(svar) ]
# Años a descargar.
year = [ int( sys.argv[2] ), int( sys.argv[3] ) ]

# Revisamos que las variables tengan el formato correcto.
if not ( svar in svars ):
    raise ValueError( "Variable inválida." )
if not ( year[0] in range(1981, 2023) ):
    raise ValueError( "Año inicial inválido." )
if not ( year[1] in range(1981, 2023) ):
    raise ValueError( "Año final inválido." )

# Escogemos todos los meses, días, y horas.
years  = list( map( lambda x: f"{x}", range( year[0], year[1] ) ) )
months = list( map( lambda x: f"{x:02d}", range(1, 13) ) )
days   = list( map( lambda x: f"{x:02d}", range(1, 32) ) )
hours  = list( map( lambda x: f"{x:02d}:00", range(0, 24) ) )

# Región en la que se descargan los datos.
# Formato: ymax, xmin, ymin, xmax 
region = [ 50, -135, -5, -65 ]
nregion = "mexico"

# Carpeta para descargar los archivos.
fdir = "../data/ERA5/" + svar + "/"
# Si no existe la carpeta, la crea.
if not os.path.exists(fdir): os.mkdir(fdir)

# Nombre del archivo a descargar.
fname = ( fdir + nregion + "_" + svar
    + "_" + years[0] + "_" + years[-1] + ".grib" )

# Formato para la petición a CDSAPI.
request = {
            "product_type": "reanalysis",
            "format": "grib",
            "variable": var,
            "year": years,
            "month": months,
            "day": days,
            "time": hours,
            "area": region,
        }

# Petición a CDSAPI.
c = cdsapi.Client()
c.retrieve( dataset, request, fname )
