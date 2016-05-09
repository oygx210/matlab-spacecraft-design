function [payload] = CreatePayload(option)

if option == 1
    % MicroMAS
    comp = struct('Name','Payload','Subsystem','Payload','Shape','Rectangle','Mass',1,'Dim',[.1,.1,.1],'CG_XYZ',[],'Vertices',[],'LocationReq','Specific','Orientation',[],'Thermal',[],'InertiaMatrix',[],'RotateToSatBodyFrame', [],'isFit',[]);
    payload.comp = comp;
    payload.Orbit = 'LEO';
    payload.h = 400; % Altitude %km
    payload.i = 51.6; % Inclination
    payload.dataperday = 5e9;   % Data per day cubesat 
    payload.lifetime = 3;     % Lifetime
    payload.mass = 1; %kg
    payload.power = 5;
    payload.cost = 200; %($ in thousands of dollars)
elseif option == 2
    % Comms satellite.
    comp = struct('Name','Payload','Subsystem','Payload','Shape','Cylinder','Mass',1,'Dim',[.1,.5],'CG_XYZ',[],'Vertices',[],'LocationReq','Specific','Orientation',[],'Thermal',[],'InertiaMatrix',[],'RotateToSatBodyFrame', [],'isFit',[]);
    payload.comp = comp;
    payload.Orbit = 'LEO';
    payload.h = 1440; % Altitude %km
    payload.i = 0; % Inclination
    payload.dataperday = 13.61*3600*24*10^3;   %GB/s converted to MB/days (data/day)
    payload.lifetime = 3;     % Lifetime
    payload.mass = 100; %kg
    payload.power = 120;
    payload.cost = 100;
end

% components(i).Name = 'Fuel Tank';
% components(i).Subsystem = 'Propulsion';
% components(i).Shape = 'Sphere';
% components(i).Mass = 150;
% components(i).Dim = 0.4;
% % components(1).isFit = 0;
% components(i).CG_XYZ = [];
% components(i).Vertices = [];
% components(i).LocationReq = 'Specific';
% components(i).Orientation = [];
% components(i).Thermal = [];
% components(i).InertiaMatrix = [];
% components(i).RotateToSatBodyFrame = [];






