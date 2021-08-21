# Calcula la precipitacion mensual media para el periodo
# 1979 - 2020 en la Cuenca del Valle de México.

import os


import pandas as pd
import xarray as xr

import matplotlib.pyplot as plt


path_cru = os.getcwd() +  "/data/CRU/"
path_r = os.getcwd() +  "/results/"
fname_cru = "mexico_cru_ts4.05.1901.2020.pre.dat.nc"
fname_grid = "grid_points.csv"

# Se leen los límites de la cuenca.
df_grid = pd.read_csv(path_r + fname_grid)
lon_i = df_grid.lonp.min()
lon_f = df_grid.lonp.max() + 1
lat_i = df_grid.latp.min()
lat_f = df_grid.latp.max() + 1

# Se carga la precipitación.
with xr.load_dataset(path_cru + fname_cru) as pre_xr:
    # Se recorta la zona de estudio.
    pre_xr = pre_xr[dict(lon = slice(lon_i, lon_f), lat = slice(lat_i, lat_f))]
    # Se promedia espacialmente y se retira stn, que no se requiere.
    pre_df = pre_xr.drop("stn").mean(dim = "lat").mean(
        dim = "lon").to_dataframe()

# Se seleccionan los datos a partir de 1979.
pre_df = pre_df[pre_df.index > "1979"]
# Se obtienen los nombres de los meses.
pre_df["Mes"] = pre_df.index.month_name("es_MX")
# Se cambia el formato del índice para que no incluya el día.
pre_df.index = pre_df.index.to_period("M")

# Se grafica el promedio mensual.
pre_mes = pre_df.groupby(pre_df.index.month).mean()
pre_mes.rename_axis("Mes", axis = "index", inplace = True)
pre_mes.plot.bar(legend = None)

# Se configura la gráfica.
plt.xlabel("Mes")
plt.ylabel("Precipitación [mm]")
plt.title(
    "Precipitación media en la\nCuenca del Valle de México",
    {'fontsize': 18}
    )
plt.xticks(range(0,12), pre_df.Mes[0:12], rotation = 30, ha = "right")

# Se guarda la gráfica.
plt.savefig("./results/mean_pre.png", facecolor = "white", bbox_inches="tight")

# Análisis de temporada de lluvias.
txt = ("Precipitación total: " + str(pre_mes.sum()[0])
    + "\nPorcentaje de precipitación total de mayo a octubre: "
    + str(pre_mes.iloc[4:10].sum()[0] / pre_mes.sum()[0])
    + "\nPorcentaje de precipitación total de junio a septiembre: "
    + str(pre_mes.iloc[5:9].sum()[0] / pre_mes.sum()[0]))

pre_mes.to_csv(path_r + "lluvias.csv")
with open(path_r + "temp_lluvias.txt", "w", encoding = "utf-8") as f:
    f.writelines(txt)