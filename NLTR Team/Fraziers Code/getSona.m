function [V,T] = getSona(frequency,power)

essparam; % Sets common parameters for equipment
aveOverSams = samNum;
[Ipulse,Qpulse,Marker]=pulseMaker(fSamAWG, pulsePeriod, pulseWidth, startPulse, awgMarkerWidth); % Creates a Gaussian pulse with given parameters
%Ipulse = ones(size(Ipulse)); Qpulse = zeros(size(Qpulse)); %LC: for testing purposes
% Send pulse to AWG and to PSG 
MM_Awg(Ipulse, Qpulse, Marker, fSamAWG); % Sends the created pulse to the AWG
MM_Psg(frequency, power, 'IQ'); % Modulates the pulse from the AWG with given frequency and power
pause(instDelay); % Sets delay time for the instruments to work

% Retrieive sona from DSO
horiDelay=(.5-startPulse).*pulsePeriod;  % Sets horizontal delay (FIGURE OUT THIS FORMULA)
voltScale=1; % One Volt per Division
%[V, T]=MM_Dso(samNum,jitSam,measCh,trigCh,fSam,horiDelay,timeScale,voltScale);
[V, T]=MM_Dso_avg(samNum,jitSam,measCh,trigCh,fSam,horiDelay,timeScale,voltScale,fillScreen,aveOverSams);    
while (max(V{1})==0 || max(T)==0) % makes sure there actually is data
	%[V, T]=MM_Dso(samNum,jitSam,measCh,trigCh,fSam,horiDelay,timeScale,voltScale);
    [V, T]=MM_Dso_avg(samNum,jitSam,measCh,trigCh,fSam,horiDelay,timeScale,voltScale,fillScreen,aveOverSams);
end
V = V{1};
V = V(1:length(T));
end