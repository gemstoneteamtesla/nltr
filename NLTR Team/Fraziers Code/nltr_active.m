%% PRECONDITIONS: 
 % AWG output is to a power splitter of the correct frequency range.
   % Port A: Connection to Port 2 of DSO
   % Port B: Linear connection to AWG/PSG
   % Port C: Nonlinear (frequency doubled) connection to AWG/PSG
 
%POSTCONDITIONS:
 % Returns three graphs:
    % 1. Graph of the recorded sona at port A, which should have
    % Fourier peaks at (frequency) and at (2*frequency). 
    % 2. Graph of the simultaneous reconstructions at ports B and C from emitting the
    % unfiltered sona from port A. There should be distinct reconstructions
    % at both.
    % 3. Graph of each individual reconstruction at ports B and C from
    % emitting the bandpass-filtered sonas.
    
% AUTHOR: Andrew Simon
% CREATED: 10/8/2014
% LAST MODIFIED:
%% Set Parameters:
 % frequency is the center frequency of the emitted pulse, in Hz
 % power is the emitted power of the pulse, in dBm
 % linearPort and nonlinearPort are integers 1-4 which specify which
 % oscilloscope port is which
clc;clear all; close all;
frequency = 3.8E9;
power = 20;
linearPort = 2; nonlinearPort = 3;

%% Get Combined Linear + Nonlinear Sona
[sonaV,sonaT] = getSona(frequency,power);
figure(1);
subplot(2,1,1),plot(sonaT,sonaV); title('Recorded Sona'); xlabel('Time(s)'); ylabel('Voltage (V)');
[fV,F] = getFFT(sonaV,sonaT);
subplot(2,1,2), plot(F,fV); title('Sona FFT'); xlabel('Freq (Hz)'); ylabel('Voltage (V)');

%% Time reverse and reconstruct at both ports simultaneously
display('Move cables now, then press any key to continue'); pause;
   % Port A: Linear connection to AWG/PSG (remove power splitter!)
   % Port B: Connection to linearPort on DSO
   % Port C: Connection to nonlinearPort on DSO
[lReconV,nlReconV,lReconT,nlReconT] = getRecon2(frequency,power,sonaV,linearPort,nonlinearPort);
figure(2);
subplot(2,1,1),plot(lReconT,lReconV); title('Unfiltered Linear Reconstruction'); xlabel('Time(s)'); ylabel('Voltage (V)');
subplot(2,1,2), plot(nlReconT,nlReconV); title('Unfiltered Nonlinear Reconstruction'); xlabel('Time(s)'); ylabel('Voltage (V)');

%% Filter each sona and reconstruct at each ports separately
[linearSona,nonlinearSona] = filterSona(sonaV,frequency,2*frequency);
[filtLinearReconV,filtLinearReconT] = getRecon(frequency,power,linearSona,linearPort);
[filtNonlinearReconV,filtNonlinearReconT] = getRecon(2*frequency,power,nonlinearSona,nonlinearPort);
figure(3);
subplot(2,1,1),plot(filtLinearReconT,filtLinearReconV); title('Filtered Linear Reconstruction'); xlabel('Time(s)'); ylabel('Voltage (V)');
subplot(2,1,2), plot(filtNonlinearReconT,filtNonlinearReconV); title('Filtered Nonlinear Reconstruction'); xlabel('Time(s)'); ylabel('Voltage (V)');