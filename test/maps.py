import sys
import os

import numpy as np
import pandas as pd
import xarray as xr
import geoviews as gv
import holoviews as hv
import datetime as dt
import geopandas as gpd

import geoviews.feature as gf


path = "data/"
out_path = path + "drought/"

if sys.argv[1] == "climate-indices":
    data_path = path + "climate-indices/"
elif sys.argv[1] == "SPEI-database":
    data_path = path + "SPEI-database"

if not os.path.exists(path): os.mkdir(path)
if not os.path.exists(out_path): os.mkdir(out_path)
if not os.path.exists(data_path): os.mkdir(data_path)

spi_ds = xr.open_dataset(data_path + "mexico_spi_pearson_06.nc").load()
spei_ds = xr.open_dataset(data_path + "mexico_spei_pearson_06.nc").load()

spi_ds2 = spi_ds[dict(lat = slice(10, 12), lon = slice(39, 41))]
spi_ds2 = spi_ds2.mean(dim = "lat").mean(dim = "lon")
spi_ds2 = spi_ds2.sel(time = slice("1901-10-16", "2021-10-16", 12))

spei_ds2 = spei_ds[dict(lat = slice(10, 12), lon = slice(39, 41))]
spei_ds2 = spei_ds2.mean(dim = "lat").mean(dim = "lon")
spei_ds2 = spei_ds2.sel(time = slice("1901-10-16", "2021-10-16", 12))

spi_df = spi_ds2.to_dataframe()
spei_df = spei_ds2.to_dataframe()

df = pd.concat([spi_df, spei_df], axis = 1)
df = df[df.index > "1970"]

gr = df.copy()
gr.index = gr.index.to_period("Y")
plot = gr.plot.line()
plot.figure.savefig(out_path + "years.png")
with open(out_path + "correlation", "w") as f:
    f.write(f"Correlación: {df.corr().iat[1, 0]}")

df_min_spi = df.sort_values(by = ["spi_pearson_06"])
df_min_spei = df.sort_values(by = ["spei_pearson_06"])

spi = True

if spi: df_min = df_min_spi
else: df_min = df_min_spei

df_min.reset_index(inplace = True)

df_min.head().to_csv(out_path + "years.csv")

kdims = ["time", "lon", "lat"]
spi_vdims = ["spi_pearson_06"]
spei_vdims = ["spei_pearson_06"]

gv.extension('matplotlib')
gv.output(size = 150)

opts = dict(colorbar = True, cmap = "bwr_r")

spi_ds = spi_ds.sel(time = list(df_min.loc[0:4, "time"]))
spi = gv.Dataset(spi_ds, kdims = kdims, vdims = spi_vdims)

spei_ds = spei_ds.sel(time = list(df_min.loc[0:4, "time"]))
spei = gv.Dataset(spei_ds, kdims = kdims, vdims = spei_vdims)

fdir = path + "Cuencas/Regiones Hidrológicas Administrativas "
fdir += "(Organismos de Cuencas) Coordenadas Geográficas/"
fname = "rha250kgw.shp"

gdf = gpd.read_file(fdir + fname)
gdf["boundary"] = gdf.boundary
cuenca = gv.Path(gdf[gdf["ORG_CUENCA"] == "Aguas del Valle de México"]).opts(
    color = "black", linewidth=1.25)

fdir = path + "Cuencas/Contorno de México 1-4,000,000/"
fname = "conto4mgw.shp"
gdf = gpd.read_file(fdir + fname)
mexico = gv.Path(gdf).opts(color = "black", linewidth=1.25)

img_spi = (spi.to(gv.Image, ["lon", "lat"]).opts(**opts)
    * gf.coastline * cuenca * mexico)
hv.save(img_spi, out_path + "spi.html")
'''
spi = spi.to(gv.Image, ["lon", "lat"]).opts(**opts)

for date in df_min["time"]:
    img_spi = spi.select(time = date) * gf.coastline * cuenca * mexico
    #img_spei = spei.select(time = date).to(gv.Image, ["lon", "lat"]).opts(
    #    **opts) * gf.coastline * cuenca * mexico)
    hv.save(img_spi, out_path + "spi" + str(date) + ".png")
    #gv.save(img_spei, out_path + "spei" + str(date) + ".png")
'''
'''
tm = np.array([tuple(df_min.loc[0:4, "time"])]).T
tm = np.repeat(tm, 5, axis = 1)

time = np.array([(
    dt.timedelta(days = 0),
    dt.timedelta(days = 30),
    dt.timedelta(days = 61),
    dt.timedelta(days = 92),
    dt.timedelta(days = 122),
    dt.timedelta(days = 153)
    )])
time = np.repeat(time, 5, axis = 0)
time = tm - time

spi_1 = xr.open_dataset(
    data_path + "mexico_spi_pearson_01.nc").load()
spei_1 = xr.open_dataset(
    data_path + "mexico_spei_pearson_01.nc").load()

spi1 = []
spi1_2 = []
spei1 = []
spei1_2 = []

for i in range(0,5):
    spi1.append(spi_1.sel(time = list(time[i])))
    spi1_2.append(spi1[i][dict(lat = slice(10, 12), lon = slice(39, 41))].mean(
        dim = "lat").mean(dim = "lon").to_dataframe())
    spei1.append(spei_1.sel(time = list(time[i])))
    spei1_2.append(spei1[i][dict(lat = slice(10, 12), lon = slice(39, 41))].mean(
        dim = "lat").mean(dim = "lon").to_dataframe())

spi1_vdims = ["spi_pearson_01"]
spei1_vdims = ["spei_pearson_01"]

for i in range(0,5):
    img_spi = gv.Dataset(spi1[i], kdims = kdims, vdims = spi1_vdims)
    img_spi = (img_spi.to(gv.Image, ["lon", "lat"]).opts(**opts)
        * gf.coastline * cuenca * mexico)
    img_spei = gv.Dataset(spei1[i], kdims = kdims, vdims = spei1_vdims)
    img_spei = (img_spei.to(gv.Image, ["lon", "lat"]).opts(**opts)
        * gf.coastline * cuenca * mexico)
    for j in range(0,6):
        gv.save(img_spi[j], out_path + "spi/" + str(i) + "_" + str(j) +".png")
        gv.save(img_spei[j], out_path + "spei/" + str(i) + "_" + str(j) +".png")
'''