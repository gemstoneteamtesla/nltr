function [V,T] = getSona(frequency,power)

essparam; % Sets common parameters for equipment

[Ipulse,Qpulse,Marker]=pulseMaker(fSamAWG, pulsePeriod, pulseWidth, startPulse, awgMarkerWidth); % Creates a Gaussian pulse with given parameters

% Send pulse to AWG and to PSG 
MM_Awg(Ipulse, Qpulse, Marker, fSamAWG); % Sends the created pulse to the AWG
MM_Psg(frequency, power, 'IQ'); % Modulates the pulse from the AWG with given frequency and power
pause(instDelay); % Sets delay time for the instruments to work

% Retrieive sona from DSO
horiDelay=(.5-startPulse).*pulsePeriod;  % Sets horizontal delay (FIGURE OUT THIS FORMULA)
voltScale=1; % One Volt per Division
[V, T]=MM_Dso(samNum,jitSam,measCh,trigCh,fSam,horiDelay,timeScale,voltScale);
    
while (max(V)==0 || max(T)==0) % makes sure there actually is data
	[V, T]=MM_Dso(samNum,jitSam,measCh,trigCh,fSam,horiDelay,timeScale,voltScale);
    %Is this while loop really necessary? 
end
end