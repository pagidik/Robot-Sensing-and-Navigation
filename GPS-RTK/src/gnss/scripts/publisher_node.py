#!/usr/bin/env
from tokenize import String
import rospy
import numpy as np
import serial
from std_msgs.msg import Float64
from math import  pi
import utm
from gnss.msg import gnss

if __name__ == '__main__':
    SENSOR_NAME = "gnss"
    rospy.init_node('gnss_driver')
    serial_port = rospy.get_param('~port','/dev/ttyACM0')
    serial_baud = rospy.get_param('~baudrate',56700)
    latitude_deg = rospy.get_param('~latitude', 41.526)

    port = serial.Serial(serial_port, serial_baud, timeout=3.)
    rospy.logdebug("Using depth sensor on port "+serial_port+" at "+str(serial_baud))

    rospy.sleep(0.2)        
    line = port.readline()
    data = str(line).split(',')

    # latitude = latitude_deg * pi / 180.
    pub = rospy.Publisher(SENSOR_NAME+'/gnss', gnss, queue_size=5)


    rospy.logdebug("Initialization complete")
    
    rospy.loginfo("Publishing gnss and UTM")

    
    try:    
        while not rospy.is_shutdown():
            line = port.readline()
            # print(line)
            
            data = str(line).split(',')
            if line == '':
                rospy.logwarn("gnss: No data")
            else:
                if data[0] == "b'$GPGGA":
                    latitude = float(data[2])
                    latdir = str(data[3])
                    longitude = float(data[4])
                    longdir = str(data[5])
                    altitude = float(data[9])
                    fix_quality = float(data[6])
                    lat_correction = 1
                    long_correction = 1

                    if latdir == "S":
                        lat_correction = -1
                    
                    if longdir == "W":
                        long_correction = -1
                        
                    print(data)
                   
                    DD = int(latitude/100)
                    SS = latitude - DD * 100
                    LatDec = lat_correction*( DD + SS/60 )

                    DD_2 = int(longitude/100)
                    
                    SS_2 = longitude - DD_2 * 100
                    LonDec = long_correction*( DD_2 + SS_2/60 ) 
                   
                    
                    utm_from_latlon = utm.from_latlon(LatDec, LonDec)
                 
                    easting = utm_from_latlon[0]
                    northing = utm_from_latlon[1]
                    zone_number = utm_from_latlon[2]
                    zone_letter = utm_from_latlon[3]
             
                    msg = gnss()
                    msg.LatDec =  LatDec
                    msg.LonDec = LonDec
                    msg.altitude = altitude
                    msg.fix_quality = fix_quality
                    msg.easting = easting
                    msg.northing = northing
                    msg.zone_number = zone_number
                    msg.zone_letter = zone_letter
                    pub.publish(msg)
  

           
    except rospy.ROSInterruptException:
        pass