# Obtiene los datos de precipitación par la Cuenca del Valle
# de Méxco a partir de CHIRPS y los promedia espacialmente.

import os


import rioxarray

import pandas as pd
import numpy as np

import geopandas as gpd
import xarray as xr


path_nc = ( os.getcwd() +
    "/results/CHIRPS_global_days_p05/cuenca_valle_mexico/" )
path_shp = ( os.getcwd() +
    "/data/Cuencas/Regiones_Hidrologicas_Administrativas/" )
path_r =  os.getcwd() + "/results/onset/"
names = ["cuenca_valle_mexico_chirps-v2.0.days_p05.nc", 
    "cuenca_valle_mexico_chirps-v2.0.2021.days_p05.nc",
    "rha250kgw.shp"]

# Si no existe la carpeta, la crea.
if not os.path.exists(path_r):
    os.mkdir(path_r)

# Se abre el archivo histórico y el del año en curso.
ds = xr.open_mfdataset(
        [path_nc + x for x in names[0:2]], combine = "nested",
        concat_dim = "time", parallel = True
        )


# Se carga el contorno de México.
gdf = gpd.read_file(path_shp + names[2])

# Se obtiene el contorno de los países.
gdf["boundary"] = gdf.boundary

# Se establece el datum de los datos.
ds = ds.rio.write_crs(gdf.crs)

# Se hace la máscara de México.
clip = ds.rio.clip(
    gdf[gdf["ORG_CUENCA"] == "Aguas del Valle de México"].geometry,
    gdf.crs, drop=False, invert=False).drop("spatial_ref")

# Precipitación diaria promedio en toda la cuenca.
df = ( clip
    .mean(dim = ["latitude", "longitude"])
    .to_dataframe() )

df["percentage"] = None

# Cantidad de puntos en la cuenca.
n = ( clip.isel(time = 0)
    .where(clip.isel(time = 0)["precip"] < 0, 1)
    .where(clip.isel(time = 0)["precip"] >= 0, 0)
    .sum(dim = ["latitude", "longitude"])
    )["precip"].values.tolist()

# Porcentaje de puntos con precipitación.
i = clip.where(clip["precip"] > 0, 0)
df.loc[i["time"].values, "percentage"] = ( i
    .where(i["precip"] <= 0, 1)
    .sum(dim = ["latitude", "longitude"])
    )["precip"].values / n

# Media móvil centrada a 15 días.
df[["precip_15", "percentage_15"]] = (
    df[["precip", "percentage"]]
    .rolling(window = 15, center = True).mean() )

# Pentada.
df[["precip_5", "percentage_5"]] = (
    df[["precip", "percentage"]]
    .rolling(window = 5, center = True).mean() )

# Datos de mayo y junio.
df2 = ( df[
    ( df.index.month == 5 ) |
    ( df.index.month == 6 ) ] )

# Se guardan los datos.
df.to_csv(path_r + "pre_daily.csv")
df2.to_csv(path_r + "pre_daily_may-jun.csv")
