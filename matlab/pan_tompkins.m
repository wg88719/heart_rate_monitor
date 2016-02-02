close all, clc, clear all
%load('ECG_sample_noisy.mat')
%ECG = ECG1;
load('../data/mit-bih/108m.mat')
fs=360;
ECG = val(1,:); %get input vector from loaded data

figure(1), 
subplot(5,1,1), plot(ECG), axis tight
title('original ECG')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%BANDPASS FILTER
fl = 5; fh = 15; %cut off frequencies of the filter
N = 3; %order fo the filter
Wn = (2/fs)*[fl fh]; %normalized frequency with respect to sampling frequency 
[b,a] = butter(N,Wn); %butterworth bandpass filter
%ECG_b = filter(b,a,ECG); %apply filter
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
[PEAK, PEAK_loc] = findpeaks(ECG_i,'MINPEAKDISTANCE', minRR);

% initialize values
initD = 2*fs; %initial delay for initializations is 2s
SPKI = max(ECG_i(1:initD)); %Signal peaks (QRS)
NPKI = 0.5*SPKI; %Noise peaks 0.5 + 0.25 - 0.5*0.25
THI1 = NPKI + 0.25 * (SPKI - NPKI);
THI2 = THI1 * 0.5; %no searchback for the moment

for i = 1 : length(PEAKI) %search throughout all the peaks

        if PEAKI(i) > THI1 %peak is detected as QRS 
                SPKI = 0.125*PEAKI(i) + 0.875*SPKI;
                in_QRSI(i) = PEAKI_loc(i); % save place of qrs
                QRSI(i) = PEAKI(i);
        %elseif PEAK(i) > TH2 %searchback ?
        else %noise
                NPKI = 0.125*PEAKI(i) + 0.875*NPKI;
        end

        THI1 = NPKI + 0.25 * (SPKI - NPKI); %update threshold
        THI2 = THI1 * 0.5; %no searchback for the moment

        thresholds(i) = THI1; %save just for plotting purposes
end

hold on, scatter(in_QRSI,QRSI),
hold on, plot(PEAK_loc,thresholds,'--g'),

