#!/usr/bin/env
from tokenize import String
import rospy
import numpy as np
import serial

from std_msgs.msg import Float64
from math import  pi

from sensor_msgs.msg import Imu, MagneticField
from    tf.transformations  import  quaternion_from_euler

if __name__ == '__main__':
    SENSOR_NAME = "imu"
    rospy.init_node('imu_driver')
    serial_port = rospy.get_param('~port', '/dev/ttyUSB0')
    serial_baud = rospy.get_param('~baudrate',115200)
    sampling_rate = rospy.get_param('~sampling_rate',40)
   

    port = serial.Serial(serial_port, serial_baud, timeout=3.)
    rospy.logdebug("Using depth sensor on port "+serial_port+" at "+str(serial_baud))

    rospy.sleep(0.2)        
    line = port.readline()
    data = str(line).split(',')


    pub = rospy.Publisher(SENSOR_NAME+'/imu_data', Imu, queue_size=5)
    mag = rospy.Publisher(SENSOR_NAME+'/mag_data', MagneticField, queue_size=5)

    rospy.logdebug("Initialization complete")
    
    rospy.loginfo("Publishing imu and magnetic Field")

    sleep_time = 1/sampling_rate - 0.025

    try:    
        while not rospy.is_shutdown():
            line = port.readline()
            # print(line)
            
            data = str(line).split(',')
            
            if line == '':
                rospy.logwarn("imu: No data")
            else:
                
                if line.startswith(b'$VNYMR'):
                  
                    yaw = np.deg2rad(float(data[1]))
                    pitch = np.deg2rad(float(data[2]))
                    roll = np.deg2rad(float(data[3]))
                    magX = float(data[4])
                    magY = float(data[5])
                    magZ = float(data[6])
                    accelX = float(data[7])
                    accelY = float(data[8])
                    accelZ = float(data[9])
                    angX = float(data[10])
                    angY = float(data[11])
                    angZ = float(data[12][0:10])
                    
                    q = quaternion_from_euler(roll, pitch, yaw)

                    q1 = q[0]
                    q2 = q[1]
                    q3 = q[2]
                    q4 = q[3]                
             
                    imu = Imu()
                    magneticField = MagneticField()
                    imu.orientation.x=  q1
                    imu.orientation.y = q2
                    imu.orientation.z = q3
                    imu.orientation.w = q4

                    imu.linear_acceleration.x = accelX
                    imu.linear_acceleration.y = accelY
                    imu.linear_acceleration.z = accelZ

                    imu.angular_velocity.x = angX
                    imu.angular_velocity.y = angY
                    imu.angular_velocity.z = angZ

                    magneticField.magnetic_field.x = magX
                    magneticField.magnetic_field.y = magY
                    magneticField.magnetic_field.z = magZ

                    print(line)
                    pub.publish(imu)
                    mag.publish(magneticField)

  

           
    except rospy.ROSInterruptException:
        pass