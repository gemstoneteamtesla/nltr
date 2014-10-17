pulseWidth=50E-9; %Width of pulse in seconds
fSam=40E9; %Sampling frequency of the oscilloscope, in Hz
pulsePeriod=15E-6; %% limit to 1/2 buffersize in MM_Dso
fSamAWG=5E9; % Sampling frequency of the Arbitrary Waveform Generator, in Hz
 jitSam=100; samNum=3 ;%  1 20  
timeScale=pulsePeriod./10; 
awgMarkerWidth=100E-9;
startPulse=0.1; % Convention, displays the pulse 10 percent from left edge on scope display
instDelay = 5;	% Delay time to allow equipment to work, in seconds
measCh=2; trigCh=1; % Which cables are connected to which ports on the DSO
filtWidth = 1E9; 
trPulseLoc=0.9; % Convention, displays the time-reversed pulse 90% from left edge on scope display
fillScreen = 1;