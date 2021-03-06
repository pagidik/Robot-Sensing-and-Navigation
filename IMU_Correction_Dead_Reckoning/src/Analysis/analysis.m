clc
clear all
close all
format long;
file_path_gps = "C:\Users\kisho\OneDrive\Desktop\IMU_GPS\gps_drive.bag"

file_path = "C:\Users\kisho\OneDrive\Desktop\IMU_GPS\2022-03-03-19-25-28.bag"

file_path2 = "C:\Users\kisho\OneDrive\Desktop\IMU_GPS\2022-03-03-19-25-29.bag"

bag_gps = rosbag(file_path_gps)
bagInfo_gps = rosbag('info', file_path_gps )
bSelgps = select(bag_gps,'Topic','/GPS/lalon')
bSelgps2 = select(bag_gps,'Topic','/GPS/utm')
msgStructs1 = readMessages(bSelgps,'DataFormat','struct');
msgStructs1{1};
msgStructs0 = readMessages(bSelgps2,'DataFormat','struct');
msgStructs0{1};

bag = rosbag(file_path);
bagInfo = rosbag('info',file_path);

bag2 = rosbag(file_path2);
bagInfo2 = rosbag('info',file_path2);


bSelimu = select(bag,'Topic','/imu/imu_data')
bSelmag = select(bag2 , 'Topic' , '/imu/mag_data')

msgStructs2 = readMessages(bSelimu,'DataFormat','struct');
% msgStructs1{1};
msgStructs2{1};
msgStructs3 = readMessages(bSelmag,'DataFormat','struct');
msgStructs3{1};

%% IMU data
Yaw = cellfun(@(m) double(m.Orientation.Z), msgStructs2);
Pitch = cellfun(@(m) double(m.Orientation.Y), msgStructs2);
Roll = cellfun(@(m) double(m.Orientation.X), msgStructs2);
W = cellfun(@(m) double(m.Orientation.W), msgStructs2);
AngularVelocity_x = cellfun(@(m) double(m.AngularVelocity.X), msgStructs2);
AngularVelocity_y = cellfun(@(m) double(m.AngularVelocity.Y), msgStructs2);
AngularVelocity_z = cellfun(@(m) double(m.AngularVelocity.Z), msgStructs2);
LinearAcceleration_x = cellfun(@(m) double(m.LinearAcceleration.X), msgStructs2);
LinearAcceleration_y = cellfun(@(m) double(m.LinearAcceleration.Y), msgStructs2);
LinearAcceleration_z = cellfun(@(m) double(m.LinearAcceleration.Z), msgStructs2);
%% Mag data
MagX = cellfun(@(m) double(m.MagneticField_.X), msgStructs3);
MagY = cellfun(@(m) double(m.MagneticField_.Y), msgStructs3);
MagZ = cellfun(@(m) double(m.MagneticField_.Z), msgStructs3);
%% Time IMU
timePoints_index_imu = cellfun(@(m) int64(m.Header.Seq),msgStructs2);
timePoints_index_imu = timePoints_index_imu - min(timePoints_index_imu);
%% Time MAG
timePoints_index_mag = cellfun(@(m) int64(m.Header.Seq),msgStructs3);
timePoints_index_mag= timePoints_index_imu - min(timePoints_index_mag);

latitudePoints = cellfun(@(m) double(m.LatDeg),msgStructs1);
longitudePoints = cellfun(@(m) -double(m.LonDeg),msgStructs1);
altitudePoints = cellfun(@(m) double(m.Alt),msgStructs1);
% NumberOfSatellites = cellfun(@(m) double(m.GpsNumbSat),msgStructs1);
% HDOP = cellfun(@(m) double(m.Hdop),msgStructs1);
utmEastingPoints = cellfun(@(m) double(m.UtmE),msgStructs0);
utmNorthingPoints = cellfun(@(m) double(m.UtmN),msgStructs0);
timePoints_index_gps = cellfun(@(m) int64(m.Header.Seq),msgStructs1);
timePoints_index_gps = timePoints_index_gps - min(timePoints_index_gps);

% 
k = boundary(utmEastingPoints, utmNorthingPoints);
figure
hold on;

plot(utmEastingPoints(k),utmNorthingPoints(k),'-')
for kk = 1:length(utmEastingPoints)
t = text(utmEastingPoints(kk),utmNorthingPoints(kk),num2str(kk));
t.Color = [1 0 0];
end

hold off

% figure
% plot(utmEastingPoints(112:180),utmNorthingPoints(112:180))


figure
plot(MagX(500:3000),MagY(500:3000))
title('Original Magnetometer Data')
xlabel('X (Gauss)')
ylabel('Y (Gauss)')
axis equal
grid on
axis equal

figure 
plot(timePoints_index_imu(500:3000), Yaw(500:3000))
title('Original Yaw Data')
xlabel('Time')
ylabel('Yaw from IMU')
grid on

min_east = min(utmEastingPoints);
min_north = min(utmNorthingPoints(1:end));

for i = 1:length(utmEastingPoints)
    utmEastingPoints(i) = (utmEastingPoints(i) - min_east);
    utmNorthingPoints(i) = (utmNorthingPoints(i) - min_north);
end
utmNorthingPoints
mean(utmEastingPoints)

figure
plot(utmEastingPoints(1:end),utmNorthingPoints(1:end))
axis equal

% geoplot(latitudePoints(250:3448),longitudePoints(250:3448))

% 
% unique(NumberOfSatellites)
% 
% gravitation  = mean(sqrt((LinearAcceleration_x).^2 + (LinearAcceleration_y).^2 + (LinearAcceleration_z).^2))
% 
% 

Bank_angle = atan(mean(LinearAcceleration_y(500:3000))/(mean(LinearAcceleration_z(500:3000))));
Elevation_angle  = atan(mean(LinearAcceleration_x(500:3000))/(mean(LinearAcceleration_z(500:3000))));

% %%
% %%%%%%%%%%%%% Compensation for Elevation and bank angle %%%%%%%


R = [cos(Elevation_angle) 0 -sin(Elevation_angle);
    sin(Bank_angle)*sin(Elevation_angle) cos(Bank_angle) sin(Bank_angle)*cos(Elevation_angle);
    cos(Bank_angle)*sin(Elevation_angle) -sin(Bank_angle) cos(Bank_angle)*cos(Elevation_angle)]
% 
for i = 1:length(MagX)
MagXYZ_tilt_correction = R*[MagX(i) ; MagY(i) ; MagZ(i)];
MagX_tilt_correction(i,1) = MagXYZ_tilt_correction(1);
MagY_tilt_correction(i,1) = MagXYZ_tilt_correction(2);
MagZ_tilt_correction(i,1) = MagXYZ_tilt_correction(3);
end

figure
plot(MagX_tilt_correction(500:3000), MagY_tilt_correction(500:3000),"r")
hold off
grid on
title('Tilt Corrected Magnetometer')
xlabel('X (Gauss)')
ylabel('Y (Gauss)')
axis equal

% 
figure 
plot(timePoints_index_imu(500:3000), MagX_tilt_correction(500:3000))
hold on
plot(timePoints_index_imu(500:3000), MagZ_tilt_correction(500:3000))
hold off
% 
figure
plot(MagX_tilt_correction(500:3000),MagY_tilt_correction(500:3000))
% %%
% %%%%%%%%%%%%%%%%%%%%%% Compensating for Hard Iron Errors %%%%%%%%%%
% %%% Index Starts at 500 and ends at 3000 the time taken for 4 Calibration
% %%% Rounds %%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
alpha = (max(MagX_tilt_correction(500:3000))+min(MagX_tilt_correction(500:3000)))/2;
beta = (max(MagY_tilt_correction(500:3000))+min(MagY_tilt_correction(500:3000)))/2;
gama = (max(MagZ_tilt_correction(500:3000))+min(MagZ_tilt_correction(500:3000)))/2;
% 
MagX_correctedHard = MagX_tilt_correction - alpha;
MagY_correctedHard = MagY_tilt_correction - beta;
MagZ_correctedHard = MagZ_tilt_correction - gama;
% 
figure 
plot(timePoints_index_imu(500:3000), MagX_correctedHard(500:3000))
hold on
plot(timePoints_index_imu(500:3000), MagZ_correctedHard(500:3000))
hold off
% 
figure
plot(MagX_correctedHard(500:3000),MagY_correctedHard(500:3000),"b")
hold on 
plot(MagX_tilt_correction(500:3000),MagY_tilt_correction(500:3000), "r")
title('Hard Iron Corrected Magnetometer')
xlabel('X (Gauss)')
ylabel('Y (Gauss)')
legend('Hard Iron Corrected', 'Original')
axis equal
grid on
hold off
% 
% %%
% %%%%%%%%%%%%%%%% Compensating for Soft Iron Errors %%%%%%%%%%%%%%
% 
% fit the data to an ellipse 
% Richard Brown (2020). fitellipse.m (https://www.mathworks.com/matlabcentral/fileexchange/15125-fitellipse-m), MATLAB Central File Exchange.

[z1, a1, b1, alpha1] = fitellipse([MagX(500:3000),MagY(500:3000)]', 'linear');
hF = figure;
hAx1 = axes('Parent', hF);
h1 = plotellipse(hAx1, z1, a1, b1, alpha1, 'r.');
grid on
hold on
plot(MagX(500:3000),MagY(500:3000) , "b")
plotellipse(z1, a1, b1, alpha1)
xlabel('x (Gauss)'); 
ylabel('y (Gauss)');
title('2. Fit the data points to an ellipse');

grid on
hold on
scatter(z1(1), z1(2), 'filled', 'ko')

% rx = sqrt((MagX_correctedHard(500:3000)).^2 + (MagY_correctedHard(500:3000)).^2)
% [M,I] = max(rx)
% Thetax = asin(MagY_correctedHard(5069)/MagX_correctedHard(5069))
Thetax = alpha1;
R_soft = [cos(Thetax) sin(Thetax);
      -sin(Thetax) cos(Thetax)]


for i = 1:length(MagX_correctedHard)
      
        MagXY_soft_correction = R_soft * [MagX_correctedHard(i); MagY_correctedHard(i)];
        MagX_soft_correction(i,1) = MagXY_soft_correction(1);
        MagY_soft_correction(i,1) = MagXY_soft_correction(2);
       

end

[z, a, b, alpha2] = fitellipse([MagX_soft_correction(500:3000),MagY_soft_correction(500:3000)]', 'linear');
% hF = figure(1);
% hAx = axes('Parent', hF);
h = plotellipse(hAx1, z, a, b, alpha2, 'r.');
grid on
% hold on
plot(MagX_soft_correction(500:3000),MagY_soft_correction(500:3000) , "g")
plotellipse(z, a, b, alpha2)
xlabel('x (Gauss)'); 
ylabel('y (Gauss)');
title('2. Fit the data points to an ellipse');
grid on
axis equal
% hold on
scatter(z(1), z(2), 'filled', 'ko')
legend('Fitted Ellipse', 'Original data','','Origin');
hold off

alpha1
alpha2

%%
% %%%%%%%%% Yaw From Magnetometer And Gyro %%%%%

eulZYX= quat2eul([Roll, Pitch, Yaw, W], "ZYX" );
Yawd = eulZYX(:,3);
Yawd = unwrap(Yawd);

figure 
plot (Yawd,"g")
title('Original YAW from IMU')
xlabel('Number of readings')
ylabel('Yaw')
grid on
hold off

%%%%%%% Yaw from Corrected Mag %%%%%%%
yaw_from_mag =  atan2(-MagY_soft_correction, MagX_soft_correction);
% yaw_from_mag = deg2rad(yaw_from_mag);
yaw_from_mag = 0.94358993229319988224*unwrap(yaw_from_mag);

for i = 27759:length(yaw_from_mag)
        yaw_from_mag(i) = yaw_from_mag(i) + 6.4131  ;
end

%%%%%%% Yaw from Gyro %%%%%%%
timePoints_index_imu(end)
AngularVelocity_z1 = AngularVelocity_z;
imu_time = 0:.025:1072.275;
yaw_from_gyro = cumtrapz(double(timePoints_index_imu), AngularVelocity_z1);
yaw_from_gyrot = deg2rad(yaw_from_gyro);

yaw_from_gyrot = 1.45504 * unwrap(yaw_from_gyrot)%% -28.2081;
for i = 56597:length(yaw_from_gyrot)
        yaw_from_gyrot(i) = yaw_from_gyrot(i) + 1.8229  ;
end

figure 
plot (Yawd,"g")
hold on
plot (yaw_from_mag, "r")
plot (yaw_from_gyrot,"b")

title('YAW Comparision Scaled')
xlabel('Number of readings')
ylabel('Yaw')
legend("From IMU", "From Magnetometer", "From Gyroscope")
grid on
hold off
% yaw_from_gyrot = wrapToPi(yaw_from_gyrot)


%%
% %%%%%% Complimentary Filter %%%%%%%
fs = 40
hpf = 0.9999999997
lpf = 1 - hpf

x = highpass(yaw_from_gyrot(4300:end),hpf)
length(yaw_from_gyrot)
length(yaw_from_mag)
y = lowpass(yaw_from_mag(4300:66388),lpf)
length(x)
length(y)

a = x+y
figure
% plot(timePoints_index_mag(18823:end), a(18823:end), "b",timePoints_index_mag(18823:end),Yawd(18823:end),"r") %%,timePoints_index_mag,yaw_from_mag_scaled(1:66388),"g")
plot( a(4300:end), "b") %%,Yawd(18823:end),"r") %%,timePoints_index_mag,yaw_from_mag_scaled(1:66388),"g")

%%


% tau = 1600;
% alpha = tau/(tau+0.025) %alpha=(tau)/(tau+dt)
% mag_z = (1- alpha) * yaw_from_mag(4300:length(Yawd))
% length(mag_z)
% yaw_combined = zeros(size(Yawd(4300:length(Yawd))))

q = 0.99 
yaw_combined = (1-q) * yaw_from_mag(1:length(yaw_from_gyrot)) + q * yaw_from_gyrot;
% yaw_combined(1) = alpha * yaw_from_mag(4300) * 0.025 + mag_z(1);
% 
% for n = 2: length(Yawd)
%     yaw_combined(n,1)=(1-alpha)*yaw_from_mag(n,1) + alpha*mag_z(n,1);     
% end

figure
hold on
plot(yaw_combined,'r')
plot(Yawd,"g")
% legend()
title('YAW Comparision Complementary Filter')
xlabel('Number of readings')
ylabel('Yaw')
grid on
legend("Yaw Complementary Filter","From IMU")
hold off


%%
%%%%%%%%%%%% Velocity from Acceleration %%%%%%%%%

imu_time = 0:.025:1659.675;
length(imu_time(4300:end))

AngularVelocity_x1 = LinearAcceleration_x(1:end) - mean(LinearAcceleration_x(1:end))
ForwardVelocityFromAccl = cumtrapz(double(imu_time(1:end)) , AngularVelocity_x1);
length(imu_time)
length(AngularVelocity_x1)

figure

plot( ForwardVelocityFromAccl )
hold on
plot(AngularVelocity_x1(4300:end))
hold off

%%%%%%% Velocity from GPS %%%%%%%%%%


dt = 1
utmEast_scaled = zeros(length(ForwardVelocityFromAccl),1);
length(utmEast_scaled)
utmNorth_scaled = zeros(length(ForwardVelocityFromAccl),1);
length(ForwardVelocityFromAccl )
length(utmEastingPoints)
utmEastingPoints(end)

for i = 1:length(ForwardVelocityFromAccl )
    k = 1+ int16(i* (length(utmEastingPoints)-1)/length(ForwardVelocityFromAccl));
    utmEast_scaled (i) = utmEastingPoints(k);
    utmNorth_scaled(i) = utmNorthingPoints(k);
end
utmEast_scaled(end)

for i = 2:length(utmEast_scaled)
    delta_easting = (utmEast_scaled(i) - utmEast_scaled(i-1));
    delta_northing = (utmNorth_scaled(i)- utmNorth_scaled(i-1));
    delta (i) = sqrt(delta_easting^2 + delta_northing^2);
    vel(i) = delta(i)/dt;
    velocity_gps(i) = vel(i);
end
gps_time = 0:1:length(utmEastingPoints)

plot( velocity_gps)


%%%%%%%%%%%% Velocity from Acceleration
hp = highpass(LinearAcceleration_x, 0.2)
% for i = 1:length(LinearAcceleration_x)
%     if (LinearAcceleration_x(i) < 0.2 && LinearAcceleration_y(i) < 0.2)
%         LinearAcceleration_x(i) = 0;
%         LinearAcceleration_y(i) = 0;
%     end
% end

AngularVelocity_x1 = (LinearAcceleration_x - mean(LinearAcceleration_x));

ForwardVelocityFromAccl = cumtrapz(double(imu_time(11000:end)) , AngularVelocity_x1(11000:end));
length(AngularVelocity_x1(4300:end));
figure
plot( ForwardVelocityFromAccl(1:end),"b")
hold on
%%
%%%%%%%%%%% Velocity from GPS %%%%%%%%%%%%%%%
delta_easting = zeros(length(utmEastingPoints),1);
delta_northing= zeros(length(utmEastingPoints),1);
delta= zeros(length(utmEastingPoints),1);
vel= zeros(length(utmEastingPoints),1);
dt = 40
gps_time = 0:1:3447

for i = 4:length(utmEastingPoints)-1
    delta_easting(i) = (utmEastingPoints(i+1) - utmEastingPoints(i-3));
    delta_northing(i) = (utmNorthingPoints(i+1)- utmNorthingPoints(i-3));
    delta(i) = sqrt(delta_easting(i)^2 + delta_northing(i)^2);
    vel(i) = delta(i)/(gps_time(i+1)-gps_time(i-3));
end


% delta = sqrt((utmEast_scaled ).^2 + (utmNorth_scaled).^2)
% dt = 40
% vel = delta/dt
figure
hold on
plot( gps_time, vel,'g')
plot(2.5*imu_time(1: length(ForwardVelocityFromAccl)), ForwardVelocityFromAccl./7, "b" )
title('Forward Velociyt')
xlabel('Number of Readings')
ylabel('Forward Linear velocity')
grid on
legend("From IMU","From GPU")
hold off

%% Dead Recknoning

%%
figure
gz = cellfun(@(m) double(m.AngularVelocity.Z),msgStructs2);
gyro_yaw = cumtrapz(imu_time(10160:end),gz(10160:end));
gyro_yaw = unwrap(gyro_yaw)
nexttile

plot(imu_time(1:length(gyro_yaw)),gyro_yaw(1:end))

title('Heading vs. Time (magnometer and yaw)')
xlabel('time')
ylabel('heading')

gyro_yaw
% plot(utmEastingPoints,utmNorthingPoints,'DisplayName','GPS Plot','Color','green')
title('UTM Easting vs UTM Northing')
xlabel('UTM Easting (m)')
ylabel('UTM Northing (m)')
grid on
legend

%Calculating distance from IMU velocity
t = 1:1:length(ForwardVelocityFromAccl);
length(t)
length(ForwardVelocityFromAccl)
distance_from_imu = cumtrapz(t,ForwardVelocityFromAccl);
imu_x(1,1) = 0;
imu_y(1,1) = 0;
correction_angle = 143*pi/180;
heading_mag1 = yaw_combined + correction_angle;

for i = 2:length(distance_from_imu) 
      imu_x(i,1) = imu_x(i-1,1) + (distance_from_imu(i) - distance_from_imu(i-1))*cos(unwrap(heading_mag1(i)));
      imu_y(i,1) = imu_y(i-1,1) + (distance_from_imu(i) - distance_from_imu(i-1))*-sin(unwrap(heading_mag1(i))); 
end 

imu_x = imu_x - imu_x(1);
imu_y = imu_y - imu_y(1);

imu__x_scaled = imu_x*(10E-3)*(0.5)+80.68
imu_y_scaled = imu_y*(10E-3)*(0.5)

angle = -pi/2.5;
R = [cos(angle) sin(angle);
      -sin(angle) cos(angle)]


for i = 1:length(imu__x_scaled)
      
        imu_rotated = R * [imu__x_scaled(i); imu_y_scaled(i)];
        imu_x_rotated(i,1) = imu_rotated(1)+50;
        imu_y_rotated(i,1) = imu_rotated(2)-60;
       

end

% utmE_from_imu =sin(heading_mag_filtered).*distance_from_imu(circle_ei:length(MagX));
% utmN_from_imu =cos(heading_mag_filtered).*distance_from_imu(circle_ei:length(MagX));
figure
plot(utmEastingPoints, utmNorthingPoints,"b")
hold on
plot(imu__x_scaled,imu_y_scaled,'DisplayName','Position Plot from IMU','Color','green')

plot(imu_x_rotated,imu_y_rotated,'DisplayName','Position Plot from IMU','Color','red')
title("Travel Plot")
legend("From GPS", "From IMU", "From IMU Rotated")
xlabel('UTM Easting (m)')
ylabel('UTM Northing (m)')
grid on

%%

omega_dot(1,1) = 0;
for i = 2:length(AngularVelocity_z)
    omega_dot(i,1) = (AngularVelocity_z(i) - AngularVelocity_z(i-1))*40;
end


xc = (LinearAcceleration_y - omega_dot)./omega_dot;
% From velocity plot observation, car was stationary from time point 22000
% to 23000 i.e. from time 550 to 575, mean of abs(xc) is calculated which
% turns out to be -0.165962681533252 or 16.59 cm

mean(xc(4700:4800))


figure;
plot(timePoints_index_imu,AngularVelocity_z,'DisplayName','Omega z','Color','green')
%title('Omega x dot and Y double dot vs time','Interpreter','latex')
xlabel('Time')
ylabel('Acceleration')
grid on
legend

hold on
plot(timePoints_index_imu,omega_dot,'DisplayName','omega dot (derivative)','Color','red')

hold on
plot(timePoints_index_imu,xc,'DisplayName','xc','Color','blue')