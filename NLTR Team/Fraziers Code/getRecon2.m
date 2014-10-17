function [V1,V2,T1,T2] = getRecon2(frequency,power,sona,channel1,channel2)

essparam; %Don't need this if it is already set

numBits = ((length(sona)./fSam) / pulsePeriod);
    %numBits is the number of pulses that can fit into the time-length of
    %the recorded sona. 1 pulse = 1 bit (think about the data transmission)
pulsePeriod = pulsePeriod .* numBits; % Period of the total reconstruction. 
    % Equals the time-length of the recorded sona (length(sona)./fSam)
trPulseLoc= trPulseLoc ./ numBits; % Sets the display location of the first transmitted bit
timeScale=pulsePeriod./10; % Ten time divisions per length of recorded sona
awgMarkerStart=trPulseLoc; %Sets the marker position at the first bit location.
broadcastSig(sona, frequency, fSam, fSamAWG, awgMarkerStart, awgMarkerWidth, power); %Time reverses and broadcasts the sona back into the cavity.
pause(instDelay);

horiDelay=(0.5-trPulseLoc).*pulsePeriod;
voltScale=1;
aveOverSams = samNum;
%[V, T]=MM_Dso(samNum,jitSam,channel,trigCh,fSam,horiDelay,timeScale,voltScale);
[V1, T1]=MM_Dso_avg(samNum,jitSam,channel1,trigCh,fSam,horiDelay,timeScale,voltScale,fillScreen,aveOverSams);
[V2, T2]=MM_Dso_avg(samNum,jitSam,channel2,trigCh,fSam,horiDelay,timeScale,voltScale,fillScreen,aveOverSams);
while (max(V1{1})==0 || max(T1)==0)
 %[V, T]=MM_Dso(samNum,jitSam,channel,trigCh,fSam,horiDelay,timeScale,voltScale); %
 [V1, T1]=MM_Dso_avg(samNum,jitSam,channel1,trigCh,fSam,horiDelay,timeScale,voltScale,fillScreen,aveOverSams);
 [V2, T2]=MM_Dso_avg(samNum,jitSam,channel2,trigCh,fSam,horiDelay,timeScale,voltScale,fillScreen,aveOverSams);
end
V1 = V1{1};
V1 = V1(1:length(T1));
V2 = V2{1};
V2 = V2(1:length(T2));
end