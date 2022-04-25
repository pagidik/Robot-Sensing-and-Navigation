import pandas as pd
import numpy as np
import seaborn as sns
import matplotlib.pyplot as plt
import geopy.distance
import csv
import statistics
import math
from matplotlib import colors
from matplotlib.ticker import PercentFormatter
from scipy import stats
from mpl_toolkits import mplot3d
import matplotlib.pyplot as plt
import numpy as np

path = '/home/kishore/EECE5554/src/gnss/Analysis/open_stay-GPS-utm.csv'
with open(path) as File:
    Line_reader = csv.reader(File)
    
    x_static = []
    y_static =[]
    x = [] 
    y = []
    altitude = []
    time = list(range(1,6703))
  
#     time_moving = list(range(1,945))

    for row in Line_reader:
        x_static.append(float(row[5]))
        y_static.append(float(row[6]))

    min_x = min(x_static[1:6703])
    min_y = min(y_static[1:6703])


    ##Rescale static data by subtarcting the minimum value
    for i in range(1,6703):
        x_static[i] = x_static[i] - min_x
        y_static[i] = y_static[i] - min_y    
        
        
    mean_x = sum(x_static[1:6703])/6703
    mean_y = sum(y_static[1:6703])/6703

             
    variance = 0
    var_final = []
    err = []
    for i in range(1, 6703):
        temp_x = mean_x - x_static[i]
        temp_y = mean_y - y_static[i]
        var = pow(temp_x,2) + pow(temp_y, 2)
        variance += var
        var_final.append(var)
        err.append(math.sqrt(var))

        

    std = math.sqrt(sum(x)/4677)

    fig = plt.figure()
    ax = fig.add_subplot(projection='3d')
  
    hist, xedges, yedges = np.histogram2d(x_static, y_static, bins=100, range=[[0, 3], [0, 3]])

    # Construct arrays for the anchor positions of the 16 bars.
    xpos, ypos = np.meshgrid(xedges[:-1] + 0.25, yedges[:-1] + 0.25, indexing="ij")
    xpos = xpos.ravel()
    ypos = ypos.ravel()
    zpos = 0

    # Construct arrays with the dimensions for the 16 bars.
    dx = dy = 0.5 * np.ones_like(zpos)
    dz = hist.ravel()

    ax.bar3d(xpos, ypos, zpos, dx, dy, dz, zsort='average')

    plt.show()