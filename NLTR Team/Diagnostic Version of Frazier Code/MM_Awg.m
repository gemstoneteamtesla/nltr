function MM_Awg(Ch1, Ch2, Marker, samRate)
%PreCondi.
%Ch1, Ch2, & Marker are equal length column vectors.
%Marker is made with int32.

%AUTHOR: BINIYAM TESFAYE TADDESE.
%CREATED: SUMMER 2009
%LAST MODIFIED: JULY 13TH, 2010
%MODIFICATION: Comment out the part that uses "the Mex. pcode", and instead
%use the simple hint from Tek tech support to directly control the AWG.

%DO A STRANGE SWAP!!! (FIND OUT WHY???)
%For some STRANGE reason, it works when Ch1 and Ch2 are swapped:
silicha=Ch1; Ch1=Ch2; Ch2=silicha; clear silicha;

%Express data as integers 0->255.
Ch1 = scaleToInt(Ch1); Ch2 = scaleToInt(Ch2);

%Encode the data
binblock1 = encodeData(Ch1, Marker);
binblock2 = encodeData(Ch2, Marker);

% build binblock header
bytes1 = num2str(length(binblock1));
header1 = ['#' num2str(length(bytes1)) bytes1];
bytes2 = num2str(length(binblock2)); %These two should be the same!
header2 = ['#' num2str(length(bytes2)) bytes2];
 
% initialize the instrument
% awg = visa('agilent', 'GPIB0::3::INSTR'); %For the scope
awg = gpib('ni',0,3); %For the laptop
awg.OutputBufferSize = 3200000; %generous!
fopen(awg);
fprintf(awg,'*rst');
fprintf(awg,'*cls');
 
% create the waveforms
fprintf(awg,['wlist:waveform:new "inphase",' num2str(length(Ch1)) ',integer']);
fprintf(awg,['wlist:waveform:new "quadrature",' num2str(length(Ch2)) ',integer']);

% send the data to new waveforms
fwrite(awg,['wlist:waveform:data "inphase",' header1 binblock1],'uint8');
fwrite(awg,['wlist:waveform:data "quadrature",' header2 binblock2],'uint8');

% set channel 1&2 to new waveform
fprintf(awg,'SOURCE1:WAVEFORM "inphase"');
fprintf(awg,'SOURCE2:WAVEFORM "quadrature"');
 
% turn on channel 1&2
fwrite(awg, 'output1 on');
fwrite(awg, 'output2 on');
% have AWG begin playback
fwrite(awg, 'awgcontrol:run');
 
% close
fclose(awg);
delete(awg);
clear awg;

function out = scaleToInt(in)
%Expresses the input using integers 0->255 while 
%anchoring "0" of the input signal to "127".
if max(in)~=0 
in=in./max(abs(in));
end
in=floor(127.*in);
out=in+127;

function binblock = encodeData(chSig, Marker)
% encode the data for AWG as defined in Programmer Manual
binblock = zeros(2*length(chSig),1);
binblock(1:2:end) = bitshift(bitand(chSig,3),6);
Marker=Marker.*(2.^6); %Use marker 1<->bit #6
binblock(2:2:end) = bitshift(chSig,-2)+ Marker;
binblock = binblock';