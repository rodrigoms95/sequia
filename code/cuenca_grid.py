import pandas as pd
import numpy as np

import geoviews as gv
import geopandas as gpd

import geoviews.feature as gf

gv.extension("matplotlib")
gv.output(size = 150)

fdir = ("../data/Cuencas/Regiones Hidrologicas Administrativas (Organismos de " + 
    "Cuencas) Coordenadas Geograficas/")
fname = "rha250kgw.shp"

gdf = gpd.read_file(fdir + fname)
gdf["boundary"] = gdf.boundary

cuenca = gv.Path(
    gdf[gdf["ORG_CUENCA"] == "Aguas del Valle de México"]).opts(color = "black")

coords = [(-99.25, 20.25), (-99.25, 19.75), (-98.75, 20.25), (-98.75, 19.75)]
points = [gv.Points(x).opts(color = "k") for x in coords]