# Notebook Setup
# import all modules
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
# matplotlib inline
fig = plt.figure()
ax = plt.axes(projection='3d')

#  
path = '/home/kishore/EECE5554/src/gnss/Analysis/build_move_2-GPS-utm.csv'
with open(path) as File:
    Line_reader = csv.reader(File)
    
    x_static = []
    y_static =[]
    x = [] 
    y = []
    altitude = []
    time = list(range(1,1303))
  
#     time_moving = list(range(1,945))

    for row in Line_reader:
        x_static.append(float(row[5]))
        y_static.append(float(row[6]))
        # x.append(float(row[5]))
        # y.append(float(row[6]))
        # altitude.append(float(row[9]))

   
    # mean_alt = sum(altitude[1:1303])/700
    min_x = min(x_static[1:1303])
    min_y = min(y_static[1:1303])

    # min_x_move = min(x[1:1303])
    # min_y_move = min(y[1:1303])
    # max_x_move = max(x[1:1303])

    # print("Easting Max : ", max_x_move)

    ##Rescale static data by subtarcting the minimum value
    for i in range(1,1303):
        x_static[i] = x_static[i] - min_x
        y_static[i] = y_static[i] - min_y    
        
        
    # mean_x = sum(x_static[1:1303])/1303
    # mean_y = sum(y_static[1:1303])/1303
    

    ## Rescale moving data by subtarcting the minimum value
    for i in range(1,1303):
        x[i] = x[i] - min_x_move
        y[i] = y[i] - min_y_move

    print(min_x_move)
    print(min_y_move)
             
    variance = 0
    var_final = []
    x = []
    for i in range(1, 1303):
        temp_x = mean_x - x_static[i]
        temp_y = mean_y - y_static[i]
        var = pow(temp_x,2) + pow(temp_y, 2)
        variance += var
        var_final.append(var)
        x.append(math.sqrt(var))

        

    # std = math.sqrt(sum(x)/4677)


    # print("Mean of static Easting, Northing is : ", mean_x, ',' , mean_y)
    # print("Standard Deviation of static UTM data is : ", std)

    
    # plotting static data
    plt.figure(figsize =(16,9))

    # plt.plot(x[1:638], y[1:638], color='blue', linestyle='', linewidth = 1,
    #         marker='.', markerfacecolor='blue', markersize=10)

    # Plotting the mean
    # plt.plot(mean_x, mean_y, color='red', linestyle='', linewidth = 1, marker='.', markerfacecolor = 'red', markersize = 20)

   
   ## Plotting moving data

    # plt.plot(x[1:186], y[1:186], color='blue', linestyle='', linewidth = 1,
    #         marker='.', markerfacecolor='blue', markersize=5)

    # plt.plot(x[186:650], y[186:650], color='green', linestyle='', linewidth = 1,
    #         marker='.', markerfacecolor='green', markersize=10)


    # plt.plot(x[650:780], y[650:780], color='purple', linestyle='', linewidth = 1,
    #         marker='.', markerfacecolor='purple', markersize=10)

    # plt.plot(x[780:1303], y[780:1303], color='yellow', linestyle='', linewidth = 1,
    #         marker='.', markerfacecolor='yellow', markersize=10)

        
   


    # plt.plot(time[1:701], altitude[1:701], color='blue', linestyle='', linewidth = 1,
    #         marker='.', markerfacecolor='blue', markersize=10)

#     plt.plot(350, mean_alt, color='red', linestyle='', linewidth = 1, marker='.', markerfacecolor = 'red', markersize = 20)
    sns.regplot(x[1:186], y[1:186], ci=0, marker='.', color = 'blue')

    # sns.regplot(x[186:650], y[186:650], ci=0,  marker='.', color = 'purple')

    # sns.regplot(x[650:750], y[650:750], ci=0, marker='.', color = 'yellow')

    # sns.regplot(x[780:1303], y[780:1303], ci=0, marker='.', color = 'green')
    
    # get coeffs of linear fit

    slope, intercept, r_value, p_value, std_err = stats.linregress(x[1:186], y[1:186])

    variance = 0

    for i in range(1, 186):
        
        Y = slope* x[i] + intercept
        temp_y = Y - y[i]
        var = pow(temp_y, 2)
        variance += var
    
    std = math.sqrt(variance/185)
    
    print("standard deviation = ", std)


    plt.text(60, 2.5 , std, horizontalalignment='left', size='xx-large', color='black', weight='semibold')


    # plt.axis(min(x),max(x),0,5)

    plt.xticks(rotation = 90)
    plt.xlabel('UTM Easting')
    plt.ylabel('UTM Northing')
    plt.title('Moving near a building')


    plt.show()


### Histogram plot ###
 
 

# N_points = 1303
# n_bins = 100
 
# # Creating distribution
# # x = np.random.randn(N_points)
# # y = .8 ** x + np.random.randn(10000) + 25
# # legend = ['distribution']
 
# # Creating histogram
# fig, axs = plt.subplots(1, 1,
#                         figsize =(10, 7),
#                         tight_layout = True)
 
 
# # Remove axes splines
# for s in ['top', 'bottom', 'left', 'right']:
#     axs.spines[s].set_visible(False)
 
# # Remove x, y ticks
# axs.xaxis.set_ticks_position('none')
# axs.yaxis.set_ticks_position('none')
   
# # Add padding between axes and labels
# axs.xaxis.set_tick_params(pad = 5   )
# axs.yaxis.set_tick_params(pad = 10)
 
# # Add x, y gridlines
# axs.grid(b = True, color ='grey',
#         linestyle ='-.', linewidth = 0.5,
#         alpha = 0.6)
 
# # Add Text watermark
# # fig.text(0.9, 0.15, 'Jeeteshgavande30',
# #          fontsize = 12,
# #          color ='red',
# #          ha ='right',
# #          va ='bottom',
# #          alpha = 0.7)
 
# # Creating histogram
# N, bins, patches = axs.hist(x, bins = n_bins)
 
# # Setting color
# fracs = ((N**(1 / 5)) / N.max())
# norm = colors.Normalize(fracs.min(), fracs.max())
 
# for thisfrac, thispatch in zip(fracs, patches):
#     color = plt.cm.viridis(norm(thisfrac))
#     thispatch.set_facecolor(color)
 
# # Adding extra features   
# plt.xlabel("Distance from the mean")
# plt.ylabel("Number of Data points")
# # plt.legend(legend)
# plt.title('Static Open field histogram')
 
# # Show plot
# plt.show()
    

   


