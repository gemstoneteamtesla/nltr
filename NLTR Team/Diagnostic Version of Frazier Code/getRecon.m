function [V,T] = getRecon(f,p,sona,channel)

essparam; %Don't need this if it is already set

numBits = ((length(sona)./fSam) / pulsePeriod);
    %numBits is the number of pulses that can fit into the time-length of
    %the recorded sona. 1 pulse = 1 bit (think about the data transmission)
pulsePeriod = pulsePeriod .* numBits; % Period of the total reconstruction. 
    % Equals the time-length of the recorded sona (length(sona)./fSam)
trPulseLoc= trPulseLoc ./ numBits; % Sets the display location of the first transmitted bit
timeScale=pulsePeriod./10; % Ten time divisions per length of recorded sona
samNum = 1; %Number of samples to average over. THIS PROBABLY IS A DUPLICATE VALUE ASSIGNMENT FROM ANOTHER FUNCTION
awgMarkerStart=trPulseLoc; %Sets the marker position at the first bit location.
broadcastSig(sona, f, fSam, fSamAWG, awgMarkerStart, awgMarkerWidth, p); %Time reverses and broadcasts the sona back into the cavity.
pause(instDelay);

horiDelay=(0.5-trPulseLoc).*pulsePeriod;
voltScale=1;

[V, T]=MM_Dso(samNum,jitSam,channel,trigCh,fSam,horiDelay,timeScale,voltScale);
while (max(V)==0 || max(T)==0)
 [V, T]=MM_Dso(samNum,jitSam,channel,trigCh,fSam,horiDelay,timeScale,voltScale);
end
end