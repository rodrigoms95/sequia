# Descarga información de una variable de ERA5 Pressure Levels.

import os
import sys

import cdsapi

# Niveles de presión disponibles.
levels = [ "1", "2", "3", "5", "7", "10", "20", "30", "50", "70",
    "100", "125", "150", "175", "200", "225", "250", "300", "350",
    "400", "450", "500", "550", "600", "650", "700", "750", "775",
    "800", "825", "850", "875", "900", "925", "950", "975", "1000" ]
# Lista de variables por descargar.
vars = [
    "u_component_of_wind", 
    "v_component_of_wind",
    "geopotential",
    "specific_humidity"
    ]
# Nombre de la base de datos.
dataset = "reanalysis-era5-pressure-levels"
# Nombre corto de las variables.
svars = [ "u", "v", "gp", "q" ]

# Escogemos la variable de acuerdo con
# el argumento de la línea de comando.
#   sys.argv[1]: variable a descargar.
#   sys.argv[2]: nivel de presión.
#   sys.argv[3]: año inicial.
#   sys.argv[4]: año final (inclusive).
svar = sys.argv[1]

# Revisamos que las variables tengan el formato correcto.
if not ( svar in svars ):
    raise ValueError( "Variable inválida." )

# vars y svars tienen el mismo índice.
var  = vars[ svars.index(svar) ]
# Nivel de presión.
level = sys.argv[2]
# Años a descargar.
year = [ int( sys.argv[3] ), int( sys.argv[4] ) ]

# Revisamos que las variables tengan el formato correcto.
if not ( year[0] in range(1981, 2023) ):
    raise ValueError( "Año inicial inválido." )
if not ( level in levels ):
    raise ValueError( "Nivel de presión inválido." )
if not ( year[1] in range(1981, 2023) ):
    raise ValueError( "Año final inválido." )

# Escogemos todos los meses, días, y horas.
years  = list( map( lambda x: f"{x}", range( year[0], year[1] ) ) )
months = list( map( lambda x: f"{x:02d}", range(1, 13) ) )
days   = list( map( lambda x: f"{x:02d}", range(1, 32) ) )
hours  = list( map( lambda x: f"{x:02d}:00", range(0, 24, 12) ) )

# Región en la que se descargan los datos.
# Formato: ymax, xmin, ymin, xmax 
region = [ 40, -120, 0, -50 ]
nregion = "mexico"

# Carpeta para descargar los archivos.
fdir = "../data/ERA5/" + svar + "_" + level + "/"
# Si no existe la carpeta, la crea.
if not os.path.exists(fdir): os.mkdir(fdir)

# Nombre del archivo a descargar.
fname = ( fdir + nregion + "_" + svar + "_"
    + level + "_" + years[0] + "_" + years[-1] + ".grib" )

# Formato para la petición a CDSAPI.
request = {
            "product_type": "reanalysis",
            "format": "grib",
            "variable": var,
            "pressure_level": level,
            "year": years,
            "month": months,
            "day": days,
            "time": hours,
            "area": region,
        }

# Petición a CDSAPI.
c = cdsapi.Client()
c.retrieve( dataset, request, fname )
