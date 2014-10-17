clc;clear all; close all;

% LAST UPDATE: 10/1:
% MAJOR CHANGES: ADDED Y-AXIS UNITS TO GRAPHS, ADDED NOTES ABOUT CABLE
% SWITCHING

% TO RUN: type "tr_harmonic" and hit Enter.  Linear port should be
% connected to "lPort" on the DSO; the nonlinear port should have a
% harmonic generator connected to it.  When the message to switch cables
% appears, attach the linear port to the AWG, and the nonlinear port to
% "nlport"
% GOT A MULTIPLIER? DON'T FORGET TO PUT A "1" IN LINE 20!

%%Setting Parameters
frequency = 3.9E9; %
power = 10; % In dbm
pauseFlag = 1; % Set this to 1 if youq want intermediate pauses in the code.
freqDiode = 400E6; % This must be set to the driving frequency of the CW Series Swept Signal Generator
multiplierFlag = 1; % Set this to 1 if you are using a frequency multiplier in place of a CW Signal Generator
lPort = 2; % Port number of linear antenna on DSO
nlPort = 3; % Port number of nonlinear antenna on DSO

%% SONA AND SONA FFT
% Produce pulse, record/plot sona
[sonaV,sonaT] = getSona(frequency,power); %Broadcasts a pulse and retrieves the sona from the linear port
figure(1); % Creates a figure window if there is not already one
subplot(2,1,1),plot(sonaT,sonaV); title('Recorded Sona'); xlabel('Time(s)'); ylabel('Voltage (V)'); % Plots the recorded sona

% Fourier transform the recorded sona and plot it
[fV,F] = getFFT(sonaV,sonaT);
subplot(2,1,2), plot(F,fV); title('Sona FFT'); xlabel('Freq (Hz)'); ylabel('Voltage (V)'); % Ok, the fact that one of our graphs has units of ??? worries me.  Need to determine what this is. % Changed to Voltage (V)

%% RECONSTRUCTION AND RECONSTRUCTION FFT
if pauseFlag display('Press any key to continue'); pause;  end % If you want, pause the code operation to view the pretty plots.
display('Moving on to measure reconstruction')
power = 15; % In case you want to change your amplification now that you have the sona

[ReconLV,ReconLT] = getRecon(frequency,power,sonaV,lPort);
figure(2);
subplot(2,1,1), plot(ReconLT,ReconLV); title('Reconstruction'); xlabel('Time(s)'); ylabel('Voltage (V)');

[fR,rF] = getFFT(ReconLV,ReconLT); 
subplot(2,1,2), plot(rF,fR); title('Reconstruction FFT'); xlabel('Freq (Hz)'); ylabel('Voltage (V)');

if pauseFlag display('Press any key to continue'); pause; end
display('Moving on to separate linear and nonlinear reconstructions')

%% Experimental Ben's Crazy Shit
% Attempting to find harmonic peaks that aren't exact multiples of the
% center frequency by searching for the maximum of the fft above the main
% frequency peak.

[maxv, maxfreqpos] = max(fV);
[max2v, max2freqpos] = max(fV(maxfreqpos+50000:end));
nonlinearfreq = F(max2freqpos);


%%  LINEAR RECONSTRUCTION AND NONLINEAR RECONSTRUCTION
if multiplierFlag %Looks for nonlinear signal at 2*frequency or other frequency if using BCS
    [linearSona,nonlinearSona] = filterSona(sonaV,frequency,nonlinearfreq); %2*frequency or nonlinearfreq
    [linearReconV,linearReconT] = getRecon(frequency,power,linearSona,lPort);
    figure(3);
    subplot(2,1,1), plot(linearReconT,linearReconV); title('Linear Reconstruction'); xlabel('Time(s)'); ylabel('Voltage (V)');
    
    display('Move your cables around now, then press any key to continue'); pause;
    [nonlinearReconV,nonlinearReconT] = getRecon(nonlinearfreq,power,nonlinearSona,nlPort); %2*frequency or nonlinearfreq (D'oh!!!)
    figure(3);
    subplot(2,1,2), plot(nonlinearReconT,nonlinearReconV); title('Nonlinear Reconstruction'); xlabel('Time(s)'); ylabel('Voltage (V)');
    
    %[fN,F] = getFFT(nonlinearReconV,nonlinearReconT); 
    %figure(4);
    %plot(F,fN); title('Nonlinear Reconstruction FFT'); xlabel('Freq (Hz)'); ylabel('Voltage (V)');
else %Looks for nonlinear signals at frequency + freqDiode
    [linearSona,nonlinearSona] = filterSona(sonaV,frequency,frequency+freqDiode);
    [linearReconV,linearReconT] = getRecon(frequency,power,linearSona,lPort);
    figure(3);
    subplot(2,1,1), plot(linearReconT,linearReconV); title('Linear Reconstruction'); xlabel('Time(s)'); ylabel('Voltage (V)');

    display('Move your cables around now, then press any key to continue'); pause;
    [nonlinearReconV,nonlinearReconT] = getRecon(frequency+freqDiode,power,nonlinearSona,nlPort);
    figure(3);
    subplot(2,1,2), plot(nonlinearReconT,nonlinearReconV); title('Nonlinear Reconstruction'); xlabel('Time(s)'); ylabel('Voltage (V)');
    
    %[fN,F] = getFFT(nonlinearReconV,nonlinearReconT); 
    %figure(4);
    %plot(F,fN); title('Nonlinear Reconstruction FFT'); xlabel('Freq (Hz)'); ylabel('Voltage (V)'); %Changed "???" to Voltage
end
%%
%[nonlinearReconV,nonlinearReconT] = getRecon(5.3E9,power,nonlinearSona,3);
%figure(gcf+1);
%plot(nonlinearReconT,nonlinearReconV);

%[fN,F] = getFFT(nonlinearReconV,nonlinearReconT);
%figure(gcf+1);
%plot(F,fN);