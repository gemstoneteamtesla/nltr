function broadcastSig(sigToBroadc, fCar, fSam, fSamAWG, awgMarkerStart, awgMarkerWidth, powerBroadc)
%TIME-REVERSES AND BROADCASTS A SIGNAL
%powerBroadc = -10; %default for TR sona broadcast!

%I/Q demodulation
[I, Q] = demodulateIQ(sigToBroadc, fCar, fSam);

%  I=downsample(I,fSam./fSamAWG); Q=downsample(Q,fSam./fSamAWG);
I=resample(I,fSamAWG, fSam); Q=resample(Q,fSamAWG,fSam);

% Time-reverse the I/Q signals, and normalize them.
I=flipud(I); Q=-1.*flipud(Q);
I=I./abs(max(I)); Q=Q./abs(max(Q));

%Use awgMarkerStart to put the rising edge of the Marker!
Marker=zeros(ceil(length(I).*awgMarkerStart),1);
markerSize=ones((awgMarkerWidth).*fSamAWG,1);
Marker=[Marker;markerSize;zeros(length(I)-length(Marker)-length(markerSize),1)];
%Broadcast time-reversed sona
MM_Awg(I, Q, Marker, fSamAWG);
MM_Psg(fCar, powerBroadc, 'IQ');