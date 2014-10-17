clc;clear all; close all;
frequency = 3.8E9; %In Hz
power = 10; % In dbm

%% Get Sonas
essparam; % Sets common parameters for equipment

[Ipulse,Qpulse,Marker]=pulseMaker(fSamAWG, pulsePeriod, pulseWidth, startPulse, awgMarkerWidth); % Creates a Gaussian pulse with given parameters

% Send pulse to AWG and to PSG 
MM_Awg(Ipulse, Qpulse, Marker, fSamAWG); % Sends the created pulse to the AWG
MM_Psg(frequency, power, 'IQ'); % Modulates the pulse from the AWG with given frequency and power
pause(instDelay); % Sets delay time for the instruments to work

% Retrieive sona from DSO
horiDelay=(.5-startPulse).*pulsePeriod;  % Sets horizontal delay (FIGURE OUT THIS FORMULA)
voltScale=1; % One Volt per Division
[sona1V, sona1T]=MM_Dso(samNum,jitSam,2,trigCh,fSam,horiDelay,timeScale,voltScale);
[sona2V, sona2T]=MM_Dso(samNum,jitSam,3,trigCh,fSam,horiDelay,timeScale,voltScale);

%% TR and send back into cavity

[Recon11V,Recon11T] = getRecon(frequency,power,sona1V,2);
[Recon12V,Recon12T] = getRecon(frequency,power,sona1V,3);
figure(1);
subplot(2,1,1), plot(Recon11T,Recon11V); title('Reconstruction of Sona 1 at Port 1'); xlabel('Time(s)'); ylabel('Voltage (V)');
subplot(2,1,2), plot(Recon12T,Recon12V); title('Reconstruction of Sona 1 at Port 2'); xlabel('Time(s)'); ylabel('Voltage (V)');

[Recon21V,Recon21T] = getRecon(frequency,power,sona2V,2);
[Recon22V,Recon22T] = getRecon(frequency,power,sona2V,3);
figure(2);
subplot(2,1,1), plot(Recon21T,Recon21V); title('Reconstruction of Sona 2 at Port 1'); xlabel('Time(s)'); ylabel('Voltage (V)');
subplot(2,1,2), plot(Recon22T,Recon22V); title('Reconstruction of Sona 2 at Port 2'); xlabel('Time(s)'); ylabel('Voltage (V)');
