function [Voltage, Time] = MM_Dso(samNum, jitSam, measCh, trigCh, fSam, horiDelay, timeScale, voltScale, fillScreen) 
% samNum is # of signals collected for averaging
% jitSam is estimate of the maximum jitter in sample #.
%
%PostCondition:
%Uses anti-jitter data acquisition to collect Voltage/volt
%vs Time/sec signal.
%Both Voltage and Time are column vectors.
% AUTHOR: BINIYAM TESFAYE TADDESE.
% CREATED: JANUARY 01, 2009.
% LAST UPDATE: AUGUST 25, 2009, 09/02/09, 07/13/10, 03/25/11
% MODIFICATIONS: Adapted for the infiniium, Compatible with tr.m, 
% Option to dynamically choose voltageScale to fill the screen.
if nargin == 0 %no shifted averaging!
 samNum = 1;
 jitSam = 0; 
elseif nargin < 9
 fillScreen = true;
end

%Connect
% dso = visa('agilent', 'GPIB28::7::INSTR');%For the scope
dso = gpib('ni',0,7);%For the Laptop
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% HERE FIX ERRORS WRT SONA LENGTH, TIMEOUT
dso.inputBufferSize = 10240000; %generous! 3 200 000;
dso.timeout=120;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
pause(1);
fopen(dso);
% %TEST CONNECTION
% fprintf(dso, '*IDN?'); dsoID=scanstr(dso); display(dsoID);

%SET UP TO MEASURE
fprintf(dso, ':SYSTem:PRESet FACtory');
fprintf(dso, ':CHANnel1:DISPlay ON');
fprintf(dso, ':CHANnel2:DISPlay ON');
fprintf(dso, ':CHANnel3:DISPlay ON');
fprintf(dso, ':CHANnel4:DISPlay ON');
fprintf(dso, sprintf(':CHANNEL%d:SCALE %f', measCh, voltScale));%20mV/div
fprintf(dso, sprintf(':TIMEBASE:SCALE %s', timeScale));%1micS/div
fprintf(dso, sprintf(':CHANNEL%d:OFFSET %f', measCh, 0));
fprintf(dso, sprintf(':TIMEBASE:POSition %s', horiDelay));
fprintf(dso,':TRIGger:MODE EDGE')
fprintf(dso, sprintf(':TRIGger:EDGE:SOURce CHANnel%d',trigCh))
fprintf(dso, sprintf(':TRIGger:LEVel CHANnel%d,%f',trigCh,.5));%0.5V trigger???
fprintf(dso, sprintf(':ACQuire:SRATe %f', fSam))
fprintf(dso, 'ACQuire:AVERage OFF')

if fillScreen == true
 fprintf(dso, sprintf(':MEASURE:VMAX? CHANNEL%d', measCh)); pause(.5);
 vMax=str2double(fscanf(dso));
 fprintf(dso, sprintf(':MEASURE:VMIN? CHANNEL%d', measCh)); pause(.5);
 vMin=str2double(fscanf(dso));
 voltScale = max(abs(vMax), abs(vMin));
 voltScale = ceil(1000.*voltScale./4)./1000;
 fprintf(dso, sprintf(':CHANNEL%d:SCALE %s', measCh, voltScale));%20mV/div
end


fprintf(dso, sprintf(':WAVEFORM:SOURCE CHANNEL%d',measCh))
fprintf(dso, ':WAVeform:STReaming: OFF')%disadvantage?
fprintf(dso, ':WAVEFORM:FORMAT WORD')
fprintf(dso, ':WAVeform:BYTeorder LSBFirst')
fprintf(dso, ':SYSTEM:HEADER OFF')
fprintf(dso, ':WAVeform:POINts?');pause(.5);
recLength=str2double(fscanf(dso));

%Measure
runningSum = [];
fail = 0;
for collection = 1:samNum
%  try
    fprintf(dso, ':STOP');
    fprintf(dso, ':WAVEFORM:DATA?');pause(1);
    header=fscanf(dso, '%c', 1);
    if (header == '#')
        x = str2double(fscanf(dso, '%c', 1));
        yyy = str2double(fscanf(dso, '%c', x));
% 		try(lol)
        readVal = fread(dso, yyy./2, 'int16');
% 		catch
% 		 display(x);
% 		 display(yyy);
% 		 rethrow(lol);
% 		end
		%Revisit use of 'recLength' for WORD vs BYTE
    %     numDataPts = yyy./bytePerDat;    
    %     if recLength ~= numDataPts
    %         display('Error determining # of data points');
    %     end           
    else
        display('Error reading response to DATA?');
    end    
    fprintf(dso, ':RUN');
    if collection == 1 
        runningSum = readVal; 
    elseif collection ~= 1
        [resCor, lag] = xcorr(runningSum, readVal, jitSam, 'coeff');
        [val, ind] = max(resCor);
        alignedData = circshift(readVal, [lag(ind), 0]);
        runningSum = runningSum + alignedData;     
		fprintf('%d\n', collection);
	end
	
%  catch
%   collection = collection -1;
%   fprintf(dso, ':RUN');
%   fail = fail + 1
%  end
end
aveData = runningSum./samNum;

%SCALE 
fprintf(dso, ':SYSTEM:HEADER OFF')
fprintf(dso, ':WAVEFORM:YINCrement?'); pause(.5);
YINCR=str2double(fscanf(dso));
fprintf(dso, ':WAVEFORM:XINCrement?'); pause(.5);
XINCR=str2double(fscanf(dso));
% Time=[0:XINCR:XINCR.*(recLength-1)]+XINCR./2;
Time=[0:1:(length(aveData)-1)].*XINCR+XINCR./2;
Voltage=YINCR.*(aveData-mean(aveData));

% %PLOT
% figure(1); plot(Time, Voltage, 'g-'); 
% xlabel('in Seconds'); ylabel('in Volts');

%CLEAN UP
fclose(dso);
delete(dso);
clear dso;