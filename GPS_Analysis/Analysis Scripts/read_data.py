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
#  
path = '/home/kishore/EECE5554/rosbagfiles/combined.csv'
with open(path) as File:
    Line_reader = csv.reader(File)
    
    x_static = []
    y_static =[]
    x = [] 
    y = []
    altitude = []
    time = list(range(1,702))
  
#     time_moving = list(range(1,945))

    for row in Line_reader:
        x_static.append(float(row[5]))
        y_static.append(float(row[6]))
        x.append(float(row[7]))
        y.append(float(row[8]))
        altitude.append(float(row[9]))

    mean_x = sum(x_static[1:701])/700
    mean_y = sum(y_static[1:701])/700
    mean_alt = sum(altitude[1:701])/700

    
    
    
    var_final = []
    for i in range(1, 701):
        temp_x = mean_x - x_static[i]
        temp_y = mean_y - y_static[i]
        var = pow(temp_x,2) + pow(temp_y, 2)
        var_final.append(var)

    std = math.sqrt(sum(var_final))/500

#     print("Mean of static Easting, Northing is : ", mean_x, ',' , mean_y)
#     print("Standard Deviation of static UTM data is : ", std)

    
    # plotting the points
    plt.figure(figsize =(16,9))

#     plt.plot(x_static[1:701], y_static[1:701], color='blue', linestyle='', linewidth = 1,
#             marker='.', markerfacecolor='blue', markersize=10)

    # Plotting the mean
#     plt.plot(mean_x, mean_y, color='red', linestyle='', linewidth = 1, marker='.', markerfacecolor = 'red', markersize = 20)


    plt.plot(time[1:701], altitude[1:701], color='blue', linestyle='', linewidth = 1,
            marker='.', markerfacecolor='blue', markersize=10)

#     plt.plot(350, mean_alt, color='red', linestyle='', linewidth = 1, marker='.', markerfacecolor = 'red', markersize = 20)
    sns.regplot(time[1:700], altitude[1:700], ci=50, marker='.', color = 'red')

    var_final_alt = []
   
    for i in range(1, 700):
        temp_alt = altitude[i] - mean_alt
        var = pow(temp_alt,2)
        var_final_alt.append(var)

    std_alt = math.sqrt(sum(var_final_alt))/700

    print("Standard Deviation of altitude: ", std_alt)


    # plotting the moving data
#     p = sns.regplot(x[:500], y[:500], ci=50, marker='.', color = 'cyan')
#     a = p.get_lines()[0].get_xdata()[:500]
#     b = p.get_lines()[0].get_ydata()[:500]
#     c = p.get_children()[1].get_paths()
#     var_final_mo = []
#     print(np.size(b))
#     for i in range(1, 100):
#         temp_b = y[i] - b[i]
#         var = pow(temp_b,2)
#         var_final_mo.append(var)

#     std_moving = math.sqrt(sum(var_final_mo))/100



# #     c_s = np.std(b)
#     print(std_moving)
    
#     plt.axis(min(x),max(x),0,5)
    plt.xticks(rotation = 90)
    plt.xlabel('time')
    plt.ylabel('altitude')
    
    plt.title('Moving Altitude')


    plt.show()
    

   


