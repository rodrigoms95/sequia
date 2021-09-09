# Evalúa qué puntos del grid del CRU corresponden a
# la Cuenca del Valle de México.

import os


import pandas as pd
import numpy as np

import geoviews as gv
import geopandas as gpd

gv.extension("matplotlib")
gv.output(size = 150)


fdir_d = os.getcwd() +  "/data/Cuencas/Regiones_Hidrologicas_Administrativas/"
fdir_r = os.getcwd() +  "/results/"
fname = "rha250kgw.shp"

# Se cargan las regiones hidrológico administrativas.
gdf = gpd.read_file(fdir_d + fname)
# Se obtiene el contorno de las cuencas-
gdf["boundary"] = gdf.boundary

# Se selecciona la Cuenca del Valle de México.
cuenca = gv.Path(
    gdf[gdf["ORG_CUENCA"] == "Aguas del Valle de México"]).opts(
    color = "black")

# Número de puntos de grid a revisar en dirección de la longitud y la latitud.
n = 4

lon = np.empty((1, n))
lat = np.empty((n, 1))
lonp = np.empty((1, n))
latp = np.empty((n, 1))

# Pivotes iniciales de lon y lat.
lon_0 = -99.75
lat_0 = 20.75
# Número de punto de grid con respecto a los archivos mexico_cru.
lonp_0 = 38
latp_0 = 12

# Se genera la lista de longitudes y latitudes cada 0.5°.
for i in range(0,n):
    lon[0, i] = lon_0 + 0.5 * i
    lat[i, 0] = lat_0 - 0.5 * i
    lonp[0, i] = lonp_0 + 1 * i
    latp[i, 0] = latp_0 - 1 * i

# Se genera la malla.
lons = np.repeat(lon, n, axis = 0)
lats = np.repeat(lat, n, axis = 1)
lons_p = np.repeat(lonp, n, axis = 0)
lats_p = np.repeat(latp, n, axis = 1)

# Se concatenan y crean pares de lon y lat en toda la malla.
points = list(zip(lons.flatten(), lats.flatten(),
    lons_p.flatten(), lats_p.flatten()))

# Se convierten a puntos de geoviews.
points_gv = [gv.Points(x).opts(color = "black") for x in points]

carre = []

# Se crea cadena wkt de perímetro de área de influencia de los puntos de grid.
for i, element in enumerate(points):
    carre.append("POLYGON(("
        + str(element[0] - 0.25) + " " + str(element[1] - 0.25) + ", "
        + str(element[0] - 0.25) + " " + str(element[1] + 0.25) + ", "
        + str(element[0] + 0.25) + " " + str(element[1] + 0.25) + ", "
        + str(element[0] + 0.25) + " " + str(element[1] - 0.25) + ", "
        + str(element[0] - 0.25) + " " + str(element[1] - 0.25) + "))")

# Se crea GeoDataFrame con geometría a partir de wkt.
df_poly = pd.DataFrame({"geometry": carre})
df_poly["geometry"] = gpd.GeoSeries.from_wkt(df_poly["geometry"])
gdf_poly = gpd.GeoDataFrame(
    df_poly, geometry = df_poly.geometry, crs = "epsg:4326")

# Se proyecta la geometría a UTM y calcular área.
gdf_poly["Area"] = gdf_poly.to_crs("epsg:32633").area

gdf_poly["Intersect"] = 0

for i in gdf_poly.index:
    # Se calcula área de intersección entre áreas de influencia y cuenca.
    overlay = gpd.overlay(
        gdf[gdf["ORG_CUENCA"] == "Aguas del Valle de México"],
        gdf_poly[gdf_poly.index == i], how = "intersection"
        )["geometry"].to_crs("epsg:32633").area

    # Se asegura que haya ceros en el GeoDataFrame en caso de no haber
    # intersección.
    if len(overlay.index) > 0: 
        gdf_poly.loc[i, "Intersect"] = overlay[0]

# Se calcula el porcentaje de intersección entre áreas de influencia
# y cuenca.
gdf_poly["Per_intersect"] = gdf_poly["Intersect"] / gdf_poly["Area"]

# Se calcula el porcentaje del área de la cuenca cubierto por cada área
# de influencia.
gdf_poly["Per_cuenca"] = (
    gdf_poly["Intersect"] / 
    gdf[gdf["ORG_CUENCA"] == "Aguas del Valle de México"].to_crs(
    "epsg:32633").area.iloc[0]
    )

opts_yes = {"alpha": 0.3, "edgecolor": "black",
    "facecolor": "blue", "linewidth": 1.5}
opts_no  = {"alpha": 0.3, "edgecolor": "black",
    "facecolor": "red",  "linewidth": 1.5}

graph = cuenca

columns = ["lon", "lat", "lonp", "latp", "Per_intersect", "Per_cuenca"]
df_cuenca = pd.DataFrame(columns = columns)

# Se concatenan las gráficas de la cuenca y los puntos de grid.
for element in points_gv:
    graph *= element

# Se concatenan las gráficas de la cuenca y los puntos de grid.
for i in range(0, len(gdf_poly)):
    # Si el porcentaje de intersección es menor a 0.5, el área de
    # influencia se grafica de color rojo.
    if gdf_poly.Per_intersect[i] < 0.5:
        graph *= gv.Shape(gdf_poly.geometry[i]).opts(**opts_no)
    # Si el porcentaje de intersección es mayor o igual a 0.5, el
    # área de influencia se grafica de color azul.
    else:
        graph *= gv.Shape(gdf_poly.geometry[i]).opts(**opts_yes)
        # Se crea un DataFrame con la información de los puntos de
        # grid a utilizar.
        df_cuenca = df_cuenca.append({
            columns[0]: points[i][0], columns[1]: points[i][1],
            columns[2]: points[i][2], columns[3]: points[i][3],
            columns[4]: gdf_poly.at[i, columns[4]], 
            columns[5]: gdf_poly.at[i, columns[5]]},
            ignore_index = True)

# Se asegura que el número de punto de grid con respecto a los archivos
# mexico_cru sea un entero.
df_cuenca = df_cuenca.astype({columns[2]: "int32", columns[3]: "int32"})
# Se calcula la suma acumulada del área de la cuenca cubierto por cada
# área de influencia.
df_cuenca["Per_cuenca_cumsum"] = df_cuenca.Per_cuenca.cumsum()

graph.opts(
    title = "Región Hidrológico Administrativa\nAguas del Valle de México",
    fontsize = 18)

gv.save(graph, fdir_r  + "cuenca_grid.png")
df_cuenca.to_csv(fdir_r + "grid_points.csv", index = False)
