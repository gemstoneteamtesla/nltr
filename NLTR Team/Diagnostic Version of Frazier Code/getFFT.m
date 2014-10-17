function [fftV,F] = getFFT(signal, L)

Fs = 40E9;
L = length(L);

%This part is all from MATLab's website:
NFFT = 2^nextpow2(L); % Next power of 2 from length of y
Y = fft(signal,NFFT)/L;
f = Fs/2*linspace(0,1,NFFT/2+1);

fftV = 2*abs(Y(1:NFFT/2+1));
F = f;

end