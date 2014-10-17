function [I, Q] = demodulateIQ(y, fCar, fSam)
% y is the signal to be modulated. fCar, fSam are carrier and sampling
% frequencies. 
% PreCondition:-
% y must be a column vector.
% fSam > 2*fCar + BW of modulated signal
% BW of y shall be < 1GHz AND 2GHz<fCar<8GHz
% 
% PostCondition:-
% It returns (column vec) Inphase & Quadrature after demodulating y of fCar.
% 
% AUTHOR: BINIYAM TESFAYE TADDESE.
% LAST UPDATE: JANUARY 31, 2009.

t = ([0:(length(y)-1)]')./fSam;
I = y.*cos(2.*pi.*fCar.*t);
Q = y.*sin(2.*pi.*fCar.*t);

%Low Pass Filter I & Q, with cutoff much higher than their BW
%Approach 1:-
if 2.*fCar < .5.*fSam
    %CaseI 2.*fCar < 1/2 fSam
    %We need: BW << cutoff << 2fCar
    %Precondition: BW<1GHz & fCar >2GHz
    cutoffLPF = fCar; %MATLAB's modulate does this!
elseif 2.*fCar >= .5.*fSam
    %CaseII fSam > 2.*fCar > 1/2 fSam
    %There will be an ALIAS of 2fCar at fSam - 2fCar!
    %Precondition: fCar <=8GHz.
    %We need: BW << cutoff << fSam-2fCar
    cutoffLPF =(fSam - 2.*fCar)./2;
end
%Use butterworth(MATLAB's choice). It is tested to be good enough!
[b, a] = butter(5, cutoffLPF./(fSam./2));
%  figure(1); freqz(b, a, 512, fSam);
I = filtfilt(b, a, I);
Q = filtfilt(b, a, Q);