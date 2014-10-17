
function [Ipulse, Qpulse, Marker] = pulseMaker(fSamAWG,pulsePeriod,pulseWidth,startPulse,awgMarkerWidth)
%Returns a gaussian pulse with the specified pulseWidth using I/Q format.
Qpulse=zeros(ceil(fSamAWG.*pulsePeriod),1);
Ipulse=zeros(ceil(length(Qpulse).*startPulse),1);
IpulseSize=ones(pulseWidth.*fSamAWG,1);
sd=(1./6).*length(IpulseSize);
gaussian = (1./sqrt(2.*pi.*(sd.^2))).*exp((-1./(2.*(sd.^2))).*((([1:length(IpulseSize)]-length(IpulseSize)./2)).^2));
IpulseSize = gaussian'.*IpulseSize;
IpulseSize = IpulseSize./abs(max(IpulseSize));
Ipulse=[Ipulse;IpulseSize;zeros(length(Qpulse)-length(Ipulse)-length(IpulseSize),1)];
Marker=zeros(ceil(length(Qpulse).*startPulse),1);
markerSize=ones((awgMarkerWidth).*fSamAWG,1);
Marker=[Marker;markerSize;zeros(length(Qpulse)-length(Marker)-length(markerSize),1)];