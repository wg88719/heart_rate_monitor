close all, clc, clear all
load('../../data/mit-bih/101m.mat') %load data
fs=360;
ECG = val(1,:); %get input vector from loaded data
%ECG = val(1,1:length(val)/2); %get input vector from loaded data

figure(1), 
subplot(4,1,1), plot(ECG), axis tight
title('original ECG')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%DIFFERENTIATOR
%difference equation: y(n)= x[n] -x[n-Nd]
Nd = round(3*fs/128) -1;
b = [1 zeros(1,Nd-1) -1];
a = [1];
[ECG_d z] = filter(b,a,ECG(1:Nd)); %get initial conditions accounting for delay
ECG_d = filter(b,a,ECG(Nd:length(ECG)),z);
%
subplot(4,1,2), plot(ECG_d), axis tight
title('Differentiator output')
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%MOVING WINDOW INTEGRATOR
%%% Moving average y[n] =  1/(N-1) \Sigma_{k=0}^{N-1} x[n-k]
N = Nd + 1; %window of the moving average
%b = (1/(N-1))*ones(1,N);; %this is the one on the paper but I think it's wrong
b = (1/N)*ones(1,N);;
a = [1];
ECG_i = filter(b,a,ECG_d);
%
subplot(4,1,3), plot(ECG_i), axis tight
title('integrator outout')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%SQUARING
ECG_s = ECG_i.^2;
%
subplot(4,1,4), plot(ECG_s), axis tight
title('Squaring output')
%
%%end of preprocessing stage
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%PEAK Detection stage
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
y = ECG_s; %output of the preprocessing stage
RRmin = 200e-3*fs;
QRSint=60e-3*fs;
Pth= 0.7*fs/128 + 4.7;
K=0.98164; %6214845220;

i = 1; %signal index
r = 1; %R peaks and positions index
th(1) = 0; %initial threshold

while (i < length(y))
        %State 1
        count = 0;
        peak = y(i);
        while (count <= RRmin + QRSint)
                if(y(i) > peak)
                        peak = y(i);
                        peakPos = i;
                end
                count = count + 1;
                th(i+1) = th(i);
                i = i + 1;
                if(i >= length(y)) 
                        break;
                end
        end
        Rpeak(r) = peak;
        RpeakPos(r) = peakPos;
        count = i - RpeakPos(r) - 1; %to compensate
        r = r + 1;

        %State 2
        while (count <= RRmin)
                count = count + 1;
        end

        th(i) = mean(Rpeak);

        %State 3
        while(y(i) <= th(i))
                i = i + 1;
                if(i >= length(y))
                        break;
                end
                %th(i) = th(i-1) * exp(-Pth/fs);
                th(i) = th(i-1) * K;
        end
end

hold on, plot(th,'g'), axis tight
hold on, scatter(RpeakPos,Rpeak)
figure(2),
plot(y),
hold on, plot(th,'g'), axis tight
hold on, scatter(RpeakPos,Rpeak)

%sample = linspace(1,length(ECG),length(ECG));
%','ECG_d','-ascii','-double')%,'-tabs')

%fid=fopen('../../data/ecg.dat','w');
%fprintf(fid,'%d\n',ECG);
%fclose(fid);
%
%fid=fopen('../../data/Xecg.dat','w');
%fprintf(fid,'%x\n',ECG);
%fclose(fid);
%
%fid_d=fopen('../../data/ecg_diff.dat','w');
%fprintf(fid_d,' %d\n',ECG_d);
%fclose(fid_d);
%
%fid_d=fopen('../../data/Xecg_diff.dat','w');
%fprintf(fid_d,' %x\n',ECG_d);
%fclose(fid_d);
%
%fid_i=fopen('../../data/ecg_int.dat','w');
%fprintf(fid_i,' %d\n',ECG_i);
%fclose(fid_d);
