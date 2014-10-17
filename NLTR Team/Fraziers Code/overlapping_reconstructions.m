% AUTHOR: Tim Furman
% CREATED: 10/16/2014
% LAST MODIFIED: 10/16/2014 by Andrew Simon
    % Created sections to broadcast multiple half-sonas and record the
    % gigabox response
    
%% Set Parameters:
 % frequency is the center frequency of the emitted pulse, in Hz
 % power is the emitted power of the pulse, in dBm
clc;clear all; close all;
frequency = 3.8E9;
power = 0;
channel = 2;
overlayPercent = 50; % Percent of the sona that will be overlapped

%% Get our SONA on, know what I'm saying
[sonaV,sonaT] = getSona(frequency,power);
figure(1);
subplot(2,1,1),plot(sonaT,sonaV); title('Recorded Sona'); xlabel('Time(s)'); ylabel('Voltage (V)');
[fV,F] = getFFT(sonaV,sonaT);
subplot(2,1,2), plot(F,fV); title('Sona FFT'); xlabel('Freq (Hz)'); ylabel('Voltage (V)');

%% Get the reconstruction

display('Paused, press any key to continue'); pause; display('Moving on to create reconstruction');

[reconV,reconT] = getRecon(frequency,power,sonaV,channel);
figure(2);
plot(reconT,reconV); title('Reconstruction'); xlabel('Time(s)'); ylabel('Voltage (V)');

%% Create a half-sona
if FALSE % SKIPS THIS PORTION FOR NOW. WORKING ON OVERLAPPING INSTEAD OF TRUNCATING AND CONCATENATING

display('Paused, press any key to continue'); pause; display('Moving on to create half sona reconstruction.');

sonaV2 = sonaV(floor(0.1*length(sonaV)):ceil(0.5*length(sonaV)));
sonaT2 = sonaT(floor(0.1*length(sonaT)):ceil(0.5*length(sonaT)));

%[reconV2,reconT2] = getRecon(frequency,power,sonaV2,channel);
    %Was having issues with getting matrix dimensions to agree way down in
    %the rabbit hole. Not really worth investigating.
%figure(3);
%plot(sonaT2,sonaV2); title('Half Sona Length Resonstruction'); xlabel('Time(s)'); ylabel('Voltage (V)');

%% Concatenate the half-sona (x2 half sonas)

display('Paused, press any key to continue'); pause; display('Moving on to create double half sona reconstructions');

sonaV3 = cat(1,sonaV2,sonaV2);

[reconV3,reconT3] = getRecon(frequency,power,sonaV3,channel);
figure(4);
subplot(2,1,1),plot(sonaT,sonaV3); title('Double Half Length Sona Sona'); xlabel('Time(s)'); ylabel('Voltage (V)');
subplot(2,1,2),plot(reconT3,reconV3); title('Double Half Sona Length Reconstruction'); xlabel('Time(s)'); ylabel('Voltage (V)');

%% Concatenate again (x4 half sonas)

display('Paused, press any key to continue'); pause; display('Moving on to create double double half length sona reconstructions');

sonaV4 = cat(1,sonaV3,sonaV3);
timeStep = sonaT(2)-sonaT(1);
sonaT4 = [sonaT(1):timeStep:length(sonaV4).*timeStep];
sonaT4 = sonaT4(1:length(sonaV4));

[reconV4,reconT4] = getRecon(frequency,power,sonaV4,channel);
figure(5);
subplot(2,1,1),plot(sonaT4,sonaV4); title('Double Double Half Length Sona'); xlabel('Time(s)'); ylabel('Voltage (V)');
subplot(2,1,2),plot(reconT4,reconV4); title('Double Double Half Sona Length Reconstruction'); xlabel('Time(s)'); ylabel('Voltage (V)');

end
%% Overlap sonas

overSonaV1 = [sonaV; zeros(floor(0.01*overlayPercent*length(sonaV)),1)];
overSonaV2 = [zeros(floor(0.01*overlayPercent*length(sonaV)),1); sonaV];
overSonaV = overSonaV1 + overSonaV2;
overSonaT = [sonaT(1):sonaT(2)-sonaT(1):(sonaT(2)-sonaT(1))*length(overSonaV)];
plot(overSonaV);