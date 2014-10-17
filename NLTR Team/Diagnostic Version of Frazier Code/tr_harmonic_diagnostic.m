%Rewritten version of tr_harmonic, meant to:
%Record intermediary steps during processing
%Be controlled through a function handle, rather than lines of code in the
%function itself.

%LAST UPDATE: 10/1:
%MAJOR CHANGES: ADDED Y-AXIS UNITS TO GRAPHS, ADDED NOTES ABOUT CABLE
%SWITCHING
%TO RUN: type "tr_harmonic" and hit Enter
%GOT A MULTIPLIER? DON'T FORGET TO PUT A "1" IN LINE 13!

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%THINGS TO SAVE%
%Initial sona V and T
%Unfiltered LTR Reconstruction V and T
%Filtered LTR Reconstruction V and T
%Filtered NLTR Reconstruction V and T
%All FFT data, because why not?
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Possible thing to save in future - the signal sent to the AWG, after filtering.
%Just to compare to make sure we aren't losing data midway through the process.
%A test where we compare the signal sent from the AWG to the messages sent to the AWG would also be useful



function tr_harmonic_diagnostic(fileName,frequency,interrogationPower,trPower)
    %tr_harmonic_diagnostic(frequency,pause)
clc; close all;

%BASIC PARAMETERS
folderName = strcat('\\ub2.ece.umd.edu\anlage\Team TESLA\Fall 2014\NLTR Team\Diagnostic Version of Frazier Code\Results\',fileName);
if frequency == 0
	frequency = 5.1E9;
end
if interrogationPower == 0
	interrogationPower = 15; % The power of the initial pulse, in dBm
end
if trPower == 0;
	trPower = interrogationPower; % In case you want to amplify the broadcast sona.
end
pauseFlag = 1; % Set this to 1 if youq want intermediate pauses in the code.
freqDiode = 400E6; % This must be set to the driving frequency of the CW Series Swept Signal Generator
multiplierFlag = 1; % Set this to 1 if you are using a frequency multiplier in place of a CW Signal Generator
lPort = 2; % Port number of linear antenna on DSO
nlPort = 3; % Port number of nonlinear antenna on DSO


%% SONA AND SONA FFT
% Produce pulse, record/plot sona
[sonaV,sonaT] = getSona(frequency,interrogationPower); %Broadcasts a pulse and retrieves the sona from the linear port
figure(1); % Creates a figure window if there is not already one
subplot(2,1,1),plot(sonaT,sonaV); title('Recorded Sona'); xlabel('Time(s)'); ylabel('Voltage (V)'); % Plots the recorded sona
[sonaFFTV,sonaFFTFreq] = getFFT(sonaV,sonaT);% Fourier transform of the recorded sona
subplot(2,1,2), plot(sonaFFTFreq,sonaFFTV); title('Sona FFT'); xlabel('Freq (Hz)'); ylabel('Voltage (V)'); %Plots the FFT in the same window under the sona.
save(folderName,'sonaT','SonaV','sonaFFTFreq','sonaFFTV'); %Saves the sona profile and FFT information.


%% RECONSTRUCTION AND RECONSTRUCTION FFT
if pauseFlag display('Press any key to continue'); pause;  end % If you want, pause the code operation to view the pretty plots. %I WOULD LIKE TO REMOVE THIS PAUSE.  DOES IT HAVE A PURPOSE?
display('Moving on to measure reconstruction')

[unfilteredReconV,unfilteredReconT] = getRecon(frequency,trPower,sonaV,lPort);
figure(2);
subplot(2,1,1), plot(unfilteredReconT,unfilteredReconV); title('Reconstruction'); xlabel('Time(s)'); ylabel('Voltage (V)');
[unfilteredReconstructionFFTV,unfilteredReconstructionFFTFreq] = getFFT(unfilteredReconV,unfilteredReconT); %FFT of the initial reconstruction... Why does this happen?
subplot(2,1,2), plot(unfilteredReconstructionFFTFreq,unfilteredReconstructionFFTV); title('Reconstruction FFT'); xlabel('Freq (Hz)'); ylabel('Voltage (V)');
save(folderName,'unfilteredReconT','unfilteredReconV','unfilteredReconstructionFFTFreq','unfilteredReconstructionFFTV','-append'); %Save the profile and FFT information of the first, unfiltered reconstruction.


%%  LINEAR RECONSTRUCTION AND NONLINEAR RECONSTRUCTION
if pauseFlag display('Press any key to continue'); pause; end
display('Moving on to separate linear and nonlinear reconstructions')

if multiplierFlag %Looks for nonlinear signal at 2*frequency
    [linearFilteredSonaV,nonlinearFileredSonaV] = filterSona(sonaV,frequency,2*frequency);
    [linearReconV,linearReconT] = getRecon(frequency,trPower,linearFilteredSonaV,lPort);
    figure(3);
    subplot(2,1,1), plot(linearReconT,linearReconV); title('Linear Reconstruction'); xlabel('Time(s)'); ylabel('Voltage (V)');

    display('Move your cables around now, then press any key to continue'); pause;
    [nonlinearReconV,nonlinearReconT] = getRecon(2*frequency,trPower,nonlinearFileredSonaV,nlPort); 
    figure(3);
    subplot(2,1,2), plot(nonlinearReconT,nonlinearReconV); title('Nonlinear Reconstruction'); xlabel('Time(s)'); ylabel('Voltage (V)');
	save(folderName,'linearFilteredSonaV','nonlinearFileredSonaV','linearReconT','linearReconV','nonlinearReconT','nonlinearReconV','-append'); %Save the linear and nonlinear reconstructions.

	%This code performs a final FFT of the nonlinear reconstruction, so that it can be compared to what was expected.  It has been commented out because it's generally unimportant.
    %[fN,F] = getFFT(nonlinearReconV,nonlinearReconT); 
    %figure(4);
    %plot(F,fN); title('Nonlinear Reconstruction FFT'); xlabel('Freq (Hz)'); ylabel('Voltage (V)');
else %Looks for nonlinear signals at frequency + freqDiode
    [linearFilteredSonaV,nonlinearFileredSonaV] = filterSona(sonaV,frequency,frequency+freqDiode); %2*frequency 
    [linearReconV,linearReconT] = getRecon(frequency,trPower,linearFilteredSonaV,lPort);
    figure(3);
    subplot(2,1,1), plot(linearReconT,linearReconV); title('Linear Reconstruction'); xlabel('Time(s)'); ylabel('Voltage (V)');
    
    [nonlinearReconV,nonlinearReconT] = getRecon(frequency+freqDiode,trPower,nonlinearFileredSonaV,nlPort); %2*frequency
    figure(3);
    subplot(2,1,2), plot(nonlinearReconT,nonlinearReconV); title('Nonlinear Reconstruction'); xlabel('Time(s)'); ylabel('Voltage (V)');
    
    %[fN,F] = getFFT(nonlinearReconV,nonlinearReconT); 
    %figure(4);
    %plot(F,fN); title('Nonlinear Reconstruction FFT'); xlabel('Freq (Hz)'); ylabel('Voltage (V)'); %Changed "???" to Voltage
end
%%
%[nonlinearReconV,nonlinearReconT] = getRecon(5.3E9,trPower,nonlinearFileredSonaV,3);
%figure(gcf+1);
%plot(nonlinearReconT,nonlinearReconV);

%[fN,F] = getFFT(nonlinearReconV,nonlinearReconT);
%figure(gcf+1);
%plot(F,fN);