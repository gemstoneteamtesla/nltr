function [voltCellArray, Time] = MM_Dso_avg(samNum, jitSam, measCh, trigCh, fSam, horiDelay, timeScale, voltScale, fillScreen, aveOverSams)
%PRECONDITIONS:
% samNum is # of signals to be collected
% jitSam is estimate of the maximum trigger time jitter in sample #.
% measCh is the scope channel where the measurment will be taken from
% trigCh is the channel where the trigger signal goes into the scope
% fSam is the sampling rate in Samples per Second.
% horiDelay is the horizontal delay setting applied on the scope.
% timeScale is time scale (in sec/division) on the scope
% voltScale is the voltage scale (in volt/division) on the scope
% fillScreen is a boolean; if true, the signal is scaled to maximize the
% dynamic range of the scope.
% aveOverSams is the # of samples to be averaged over. samNum/aveOverSams
% should be an integer! The ratio gives the number of column vectors in
% "voltCellArray". For example, if samNum=100 and aveOverSams=50, MM_Dso
% averages over 50 nominally identical signals twice, and it returns the
% resulting two averaged signals packaged inside "voltCellArray".
%
%
%POSTCONDITIONS:
% Time is column vector (in seconds)
% voltCellArray is a cell array of column vector(s). The column vectors
% represent nominally identical voltage signals (in volts). These nominally
% identical voltage signals can later be averaged together after alignment.
%

% AUTHOR: BINIYAM TESFAYE TADDESE.
% CREATED: JANUARY 01, 2009.
% LAST UPDATE: AUGUST 25, 2009, 09/02/09, 07/13/10, 03/25/11, 06/11/11,
% 12/13/11.
% MODIFICATIONS: Adapted for the infiniium,
% Option to dynamically choose voltageScale to fill the screen.
% Added simple conditions to check for validity of data scanned.
% Voltage is a cell array; it consists of voltages averaged over aveOverSams
% samples. If samNum == aveOverSams, it consists of a single voltage vector that is
% averaged over samNum.

if nargin <10
    aveOverSams = samNum;
    %The default is to simply average over "samNum" signals and return the
    %aligned average.
end
%ESTABLISH CONNECTION TO THE SCOPE
% dso = visa('agilent', 'GPIB28::7::INSTR');%Connect using the computer in the scope
dso = gpib('ni',0,7);%Connect using a laptop computer (or another desktop computer)
dso.inputBufferSize = 3200000; %This is a generous setting.
pause(1);
fopen(dso);
% %OPTIONALLY TEST THE CONNECTION
% fprintf(dso, '*IDN?');
% dsoID=scanstr(dso);
% display(dsoID);

%SET UP TO MEASURE
fprintf(dso, ':SYSTem:PRESet Factory');
fprintf(dso, ':CHANnel1:DISPlay ON');
fprintf(dso, ':CHANnel2:DISPlay ON');
fprintf(dso, ':CHANnel3:DISPlay ON');
fprintf(dso, ':CHANnel4:DISPlay ON');
fprintf(dso, sprintf(':CHANNEL%d:SCALE %E', measCh, voltScale));
fprintf(dso, sprintf(':TIMEBASE:SCALE %E', timeScale));
fprintf(dso, sprintf(':CHANNEL%d:OFFSET %E', measCh, 0));
fprintf(dso, sprintf(':TIMEBASE:POSition %E', horiDelay));
fprintf(dso,':TRIGger:MODE EDGE');
fprintf(dso, sprintf(':TRIGger:EDGE:SOURce CHANnel%d',trigCh));
fprintf(dso, sprintf(':TRIGger:LEVel CHANnel%d,%f',trigCh,.5));
fprintf(dso, sprintf(':ACQuire:SRATe %E', fSam));
fprintf(dso, 'ACQuire:AVERage OFF');

%DO MORE SET UPS
fprintf(dso, sprintf(':WAVEFORM:SOURCE CHANNEL%d',measCh));
fprintf(dso, ':WAVeform:STReaming: OFF');
fprintf(dso, ':WAVEFORM:FORMAT WORD');
fprintf(dso, ':WAVeform:BYTeorder LSBFirst');
fprintf(dso, ':SYSTEM:HEADER OFF');

%DYNAMICALLY ADJUST THE VOLTAGE SCALING TO MAXIMIZE THE DYNAMIC RANGE
pauseTime=0.5;
if fillScreen == true
    %first adjust voltscale to hold all the waveform inside screen
    fprintf(dso, sprintf(':CHANNEL%d:SCALE?', measCh));
    pause(pauseTime);
    voltScale=str2double(fscanf(dso));
    fprintf(dso, sprintf(':MEASURE:VMAX? CHANNEL%d', measCh));
    pause(pauseTime);
    vMax=str2double(fscanf(dso));
    while vMax > voltScale*4
        voltScale=voltScale*2;
        fprintf(dso, sprintf(':CHANNEL%d:SCALE %E', measCh, voltScale));
        pause(pauseTime);
        fprintf(dso, sprintf(':MEASURE:VMAX? CHANNEL%d', measCh));
        pause(pauseTime);
        vMax=str2double(fscanf(dso));
    end
    for i=1:2
        vMax=0;
        while vMax==0
            fprintf(dso, sprintf(':MEASURE:VMAX? CHANNEL%d', measCh));
            pause(pauseTime);
            vMax=str2double(fscanf(dso));
        end
        vMin=0; pauseTime=1;
        while vMin==0
            fprintf(dso, sprintf(':MEASURE:VMIN? CHANNEL%d', measCh));
            pause(pauseTime);
            vMin=str2double(fscanf(dso));
        end
        %display(vMax)
        %display(vMin)
        voltScale = max(abs(vMax), abs(vMin));
        voltScale = ceil(1000.*voltScale./3.5)./1000;
        fprintf(dso, sprintf(':CHANNEL%d:SCALE %E', measCh, voltScale));
        pause(pauseTime);
    end
end

%display(voltScale)
%CREATE A CELL ARRAY TO STORE SIGNALS AVERAGED OVER "aveOverSams" SIGNALS
%NOTE: samNum./aveOverSams is an integer by the precondition!
voltCellArray = cell( ceil(samNum./aveOverSams), 1 );
for ccc = 1:ceil(samNum./aveOverSams)
    %MEASURE
    runningSum = [];
    collection = 0;
    while collection < min(samNum, aveOverSams)
        collection = collection + 1;
        try
            pause(pauseTime/10)
            fprintf(dso, ':STOP');
            fprintf(dso, ':WAVEFORM:DATA?');
            pause(pauseTime);
            header=fscanf(dso, '%c', 1);
            if (header == '#')
                x = str2double(fscanf(dso, '%c', 1));
                yyy = str2double(fscanf(dso, '%c', x));
                readVal = fread(dso, yyy./2, 'int16');
            else
                error('Error in MM_Dso: Invalid response from DATA?');
            end
            fprintf(dso, ':RUN');
            if collection == 1
                runningSum = readVal;
            elseif collection ~= 1
                %THIS IS THE CRUX OF THE ALIGNED AVERAGING ALGORITHM.
                %IT IS DESIGNED TO COUNTER-ACT THE EFFECT OF TIME JITTER (characterized by jitSam)
                [resCor, lag] = xcorr(runningSum, readVal, jitSam, 'coeff');
                [val, ind] = max(resCor);
                alignedData = circshift(readVal, [lag(ind), 0]);
                runningSum = runningSum + alignedData;
            end
            if isempty(runningSum)
                error('Error in MM_Dso: Data is not read!');
            end
        catch
            collection = collection -1;
            fprintf(dso, ':RUN');
        end
    end
    aveData = runningSum./min(samNum,aveOverSams);
    %STORE IN THE CELL ARRAY TO BE RETURNED
    voltCellArray{ccc,1} = aveData;
end

%SCALE THE DATA SO THAT IT HAS THE APPROPRIATE UNITS
fprintf(dso, ':SYSTEM:HEADER OFF');
YINCR=0; pauseTime=1;
%if nargin < 11
%    pauseTimeY = 1;
%end
%display(pauseTimeY)
while YINCR==0
    fprintf(dso, ':WAVEFORM:YINCrement?');
    pause(pauseTime);
    YINCR=str2double(fscanf(dso));
    pauseTime=1;
end
XINCR=0; pauseTime=1;
while XINCR==0
    fprintf(dso, ':WAVEFORM:XINCrement?');
    pause(pauseTime);
    XINCR=str2double(fscanf(dso));
    pauseTime=1;
end

if XINCR < 1/fSam
    display(sprintf('need to correct XINCR from %e to 1/fSam=%e',XINCR,1/fSam));
end
totalT=(length(aveData)-1)*XINCR;
Time=linspace(1/fSam/2,totalT,ceil(totalT*fSam));
for ccc = 1:ceil(samNum./aveOverSams)
    Voltage=YINCR.*( voltCellArray{ccc,1} - mean(voltCellArray{ccc,1}) );
    if max(abs(Voltage)) == 0
        display('Warning: MM_Dso output is all zero!');
    end
    if XINCR < 1/fSam
        Voltage=resample(Voltage,fSam,1/XINCR);
    end
    voltCellArray{ccc,1} = Voltage;
    % %OPTIONALLY VISUALIZE THE DATA PLOT
    % figure(1); plot(Time, Voltage, 'g-');
    % xlabel('in Seconds'); ylabel('in Volts');
end
%CLOSE THE CONNECTION TO THE SCOPE, DELETE THE SCOPE OBJECT FROM THE
%WORKSPACE, AND CLEAR THE VARIABLE FOR THE NAME OF THE SCOPE OBJECT.
fclose(dso);
delete(dso);
clear dso;