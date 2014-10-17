function filtSig = bsFilter(signal, samRate, cFreq, bpBW)
%Precondition
%signal must be a column vector
%cFreq is the center of the pass band in Hz
%bpBW is the width of the pass band in Hz
%Postcondition
%Signal is bandpass filtered with the following parameters & returned.
%Signal is circularly shifted to offset the delay byproduct of filtering.

%AUTHOR: BINIYAM TESFAYE TADDESE.
%LAST MODIFIED: OCTOBER 28TH, 2009.
%MODIFICATION: Compensate for group velocity shift.


bpCenter=cFreq./(0.5.*samRate);
bpRadius=(0.5.*bpBW)./(0.5.*samRate);
%980 is order of filter, giving 490 group velo; hamming window is used
filtOrder=980;
b = fir1(filtOrder,[bpCenter-bpRadius, bpCenter+bpRadius],'stop');

filtSig = filter(b,1,signal);
filtSig = circshift(filtSig, filtOrder./2);

% 
% figure(4); %show the filter used
% freqz(b,1,512) 
% figure(5); 
% subplot(2,1,1);
% plot(filtSig, '-r'); hold on;
% plot(signal+.5, 'b');
% title('Comparing:- Signal in blue AND Filtered signal in red');
% subplot(2,1,2); 
% 
% plot( [1:1:length(signal)].*(samRate./length(signal)) ,real(fft(signal))+60); hold on;
% plot( [1:1:length(signal)].*(samRate./length(signal)) ,real(fft(filtSig)),'r-');
% title('compare in freq. domain');