function MM_Psg(Frequency, Power, ModType, pulseWidth, pulsePeriod)
%PreCondition
%Frequency in Hz, Power in dBm. 
%ModType is either PULSE or IQ.
%pulseWidth is in second & is needed for PULSE ModType.
%pulsePeriod is in second & is needed for PULSE ModType.

%AUTHOR: BINIYAM TESFAYE TADDESE. 
%LAST MODIFIED: NOVEMBER 7TH, 2010.
%MODIFICATION: Senses & gives UNLEVEL warning!

%Initialize
% psg = visa('agilent', 'GPIB0::19::INSTR');%When running it from the scope!
psg = gpib('ni',0,19); %When running it from the laptop!
fopen(psg)
%Reset
% fprintf(psg, '*RST')
set(psg,'EOSMode','read&write')
set(psg,'EOSCharCode','LF')
%Set CW Frequency and Power
fprintf(psg, sprintf('FREQuency:CW %fHz', Frequency))
fprintf(psg, sprintf('POWer %fDBM', Power))
if strcmp(ModType,'PULSE')==1
 %Turn on Pulse Modulation
 fprintf(psg, sprintf(':PULM:INT:PERiod %dS', pulsePeriod))  
 fprintf(psg, ':PULM:INT:PWIDth 500E-9S')
 fprintf(psg, ':PULM:STATe ON')
 %Turn Modulation & RF on
 fprintf(psg, ':OUTPut:MODulation ON');
 fprintf(psg, ':OUTPut ON'); 
 display('Check to see pulse: it will be shrunk.'); pause(2);
 for pw=500E-9:-10E-9:pulseWidth
    fprintf(psg, sprintf(':PULM:INT:PWIDth %dS', pw))
%     display('Shrinking pulse');
    pause(.2);
 end
 
elseif strcmp(ModType, 'IQ')==1 
 %Turn on Wide IQ Mod
 %Use PULM iff AWG & PSG are in synch!
 %fprintf(psg, ':PULM:INT:PERiod 10E-6S')
 %fprintf(psg, ':PULM:INT:PWIDth 10E-6S')
 %fprintf(psg, ':PULM:STATe ON') 
 fprintf(psg, ':WDM:STATe ON');
 %Turn Modulation & RF on
 fprintf(psg, ':OUTPut:MODulation ON');
 fprintf(psg, ':OUTPut ON'); 
end
%Check if the UNLEVEL annunciator is ON
fprintf(psg,':STATus:QUEStionable:POWer:CONDition?');
unlevelStatus=fscanf(psg);
if str2double(unlevelStatus(2))==2 
 display('Warning: UNLEVEL annunciator is ON');
end

%Clean up space
fclose(psg)
delete(psg)
clear psg