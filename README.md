# Robot-Sensing-Navigation


## GPS Analysis

Written the device driver for data aquisition.
Collected data using GlobalSat BU-353-S4 GPS Puck and analyzed stationary and straight line moving data.

## RTK GNSS System

Setup EMLID Reach one as base and other as rover. The base is stationary and sends corrections to the rover over radio and the laptop is connected to the rover via USB-serial to recieve the corrected gnss fix solution in NMEA string.

## IMU Noise Characterization with Allan Variance

Wrote IMU device driver for data collection
Hardware used is Vectornav VN-100 IMU
Performed stationary noise analysis over 15 min data. 
Characterized IMU using Allan Variance and three noise parameters N (angle random walk), K (rate random walk), and B (bias instability) are estimated using data logged from a stationary gyroscope.


## Navigation with IMU and Magnetometer

Built navigation stack using two different sensors - GPS and IMU 
Data collected using Northeastern's Autonomous car NUANCE. 
Calibrated Magnetometer by correting hard and soft iron effects and calculated yaw from corrected magnetometer readings.
Compared the yaw angle from Magnetometer and Yaw integrated from Gyro and applied a complimentary filter to combine both measurements to get improved yaw angle. 
Estimated forward velocity from both GPS and IMU measurements and compared both. 
Dead reckoning:
Integrated IMU data to obtain displacement and compared it with GPS. 

## Camera Calibration & Photo Mosaicing

Used Camera Calibration Tool box and calibrated the camera using a printed checkerboard and calcuated the reprojection error. 
Collected multiple overlapping images and detected corners using harris feature detector and used the matching fetures to make a panoramic mosaic from the images. 
