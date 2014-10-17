function [fftV,F] =  getFFT(V,T)
	fSam=40E9; %Sampling Frequency of the DSO
	F = fSam .* (1:length(T))./length(T);
	fftV = abs(fft(V));
end