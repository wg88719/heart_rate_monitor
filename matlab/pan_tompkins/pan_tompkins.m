close all, clc, clear all
%load('ECG_sample_noisy.mat')
%ECG = ECG1;
load('../../data/mit-bih/101m.mat')
fs=360;
%only 30 secs
ECG = val(1,1:length(val)/4); %get input vector from loaded data

figure(1), 
subplot(5,1,1), plot(ECG), axis tight
title('original ECG')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%BANDPASS FILTER
fl = 5; fh = 15; %cut off frequencies of the filter
N = 3; %order fo the filter
Wn = (2/fs)*[fl fh]; %normalized frequency with respect to sampling frequency 
[b,a] = butter(N,Wn); %butterworth bandpass filter
%[ECG_b z2]= filter(b,a,ECG,z1); %apply filter
ECG_b = filtfilt(b,a,ECG); %apply zero-phase forward and reverse IIR filter

subplot(5,1,2), plot(ECG_b), axis tight
title('Bandpass filter output')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%DIFFERENTIATOR
%difference equation: y(nT)=(1/8T)(-x(nT-2T)-2x(nT-T)+2x(nT+Y)+x(nT+2T))
b = [-1 -2 0 2 1]*(1/8);%1/8*fs
a = [1];
ECG_d = filter(b,a,ECG_b);

subplot(5,1,3), plot(ECG_d), axis tight
title('Differentiator output')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%SQUARING
ECG_s = ECG_d.^2;

subplot(5,1,4), plot(ECG_s), axis tight
title('Squaring output')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%MOVING WINDOW INTEGRATOR
%% Moving average Y(nt) = (1/N)[x(nT-(N - 1)T)+ x(nT - (N - 2)T)+...+x(nT)]
N = round(0.150*fs); %window of the moving average
b = (1/N)*ones(1,N);;
a = [1];
ECG_i = filter(b,a,ECG_s);

subplot(5,1,5), plot(ECG_i), axis tight
%close all,
%figure(1), plot(ECG_i), axis tight
title('Integrator output')

%end of preprocessing stage

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%DETECTION
%start of the decision stage

%find peaks
minRR = round(200e-3*fs); %%minimum physiological distance between two R peaks is about 200 ms
maxRR = round(360e-3*fs); %maximum human distance for RR intervals is 360 ms
[PEAKI, PEAKI_loc] = findpeaks(ECG_i,'MINPEAKDISTANCE', minRR); %only look for one peak in each of these intervals

% initialize values
initD = 2*fs; %initial delay for initializations is 2s
SPKI = max(ECG_i(1:initD)); %Signal peaks (QRS)
%NPKI = 0.5*SPKI; %Noise peaks 0.5 + 0.25 - 0.5*0.25
NPKI = mean(ECG_i(1:initD));
THI1 = NPKI + 0.25 * (SPKI - NPKI);
THI2 = THI1 * 0.5; %no searchback for the moment

%RRave1 = minRR;
%RR1 = zeros(1,8); %holds the last 8 RR interval values
%RR2 = zeros(1,8); %holds the last 8 RR interval values
rr1 = 0; %index for RR1 vector
rr2 = 0;

RRlow  = 0; %0.92 * RRave2;
RRhigh = 0; %1.16 * RRave2;
RRmiss = 0; %1.66 * RRave2;

ii = 1;
for i = 1 : length(PEAKI) %search throughout all the peaks

        if PEAKI(i) > THI1 %peak is detected as QRS 
                SPKI = 0.125*PEAKI(i) + 0.875*SPKI;
                QRSI_loc(ii) = PEAKI_loc(i); % save place of qrs
                QRSI(ii) = PEAKI(i);
                ii = ii + 1;
        %elseif PEAK(i) > TH2 %searchback ?
        else %noise
                NPKI = 0.125*PEAKI(i) + 0.875*NPKI;
        end

        THI1 = NPKI + 0.25 * (SPKI - NPKI); %update threshold
        THI2 = THI1 * 0.5; 

        threshold1(i) = THI1; %save just for plotting purposes
        threshold2(i) = THI2; %save just for plotting purposes

        % average RR interval 
        if  length(QRSI)  > 1 %wait for two heart beats
                if (rr1 > 7) %keep trackonly of the last 8 RR intervals
                        rr1 = 1;
                else
                        rr1 = rr1 + 1;
                end

                RR1(rr1) = QRSI_loc(ii-1) - QRSI_loc(ii-2);% the current QRS - the previous one
                RRave1 = (1/length(RR1)) * sum(RR1);
                RR(ii-1) = RR1(rr1);

                if (length(RR1) < 2) %if only one RR interval so far 
                        %initialize the limits
                        RRlow  = 0.92 * RRave1;
                        RRhigh = 1.16 * RRave1;
                        RRmiss = 1.66 * RRave1;
                end

                if ( RR1(rr1) > RRmiss ) % searchback

                elseif (RR1(rr1) < minRR & RR1(rr1) > maxRR)  %Not physiologically possible so something is wrong

                        ii = ii - 1; %go back to previous value

                elseif  (RR1(rr1) > RRlow & RR1(rr1) < RRhigh) %if it is in the limits interval
                        if (rr2 > 7)
                                rr2 = 1;
                        else
                                rr2 = rr2 + 1;
                        end

                        RR2(rr2) = RR1(rr1);

                        RRave2 = (1/length(RR1)) * sum(RR2);
                        RRlow  = 0.92 * RRave2;
                        RRhigh = 1.16 * RRave2;
                        RRmiss = 1.66 * RRave2;

                end

        end
end

hold on, scatter(QRSI_loc,QRSI),
hold on, plot(PEAKI_loc,threshold1,'--g'),
hold on, plot(PEAKI_loc,threshold2,'--m'),
%linkaxes,

%save variable ECG_i into an ascii file in double (16 bits) format delimited by tabs
%so that it can be compared with the RTL implementations
save('ECGI','ECG_i','-ascii','-double','-tabs');

%tell the heart rate
fprintf('The last average1 heart period is: %d s\n', RRave1/fs)
fprintf('The last average heart rate is: %d beats per second\n', fs/RRave1)

%figure(2),
%histogram(RR./fs)%,'DisplayStyle','bar'))

%if (RRave1 == RRave2)
%        fprintf('The heart rate is regular\n')
%else
%        fprintf('The heart rate is irregular\n')
%end


