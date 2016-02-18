close all, clc, clear all
load('../../data/mit-bih/101m.mat') %load data
fs=360;
ECG = val(1,:); %get input vector from loaded data

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
[ECG_d z] = filter(b,a,ECG(1:7)); %get initial conditions accounting for delay
ECG_d = filter(b,a,ECG(7:length(ECG)),z);
%
subplot(4,1,2), plot(ECG_d), axis tight
title('Differentiator output')
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%MOVING WINDOW INTEGRATOR
%%% Moving average y[n] =  1/(N-1) \Sigma_{k=0}^{N-1} x[n-k]
N = Nd + 1; %window of the moving average
%b = (1/(N-1))*ones(1,N);; %this is the one on the paper but I think it's wrong
b = (1/(N-1))*ones(1,N);;
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

%sample = linspace(1,length(ECG),length(ECG));
%','ECG_d','-ascii','-double')%,'-tabs')

fid=fopen('../../data/ecg.dat','w');
fprintf(fid,'%d\n',ECG);
fclose(fid);

fid=fopen('../../data/Xecg.dat','w');
fprintf(fid,'%x\n',ECG);
fclose(fid);

fid_d=fopen('../../data/ecg_diff.dat','w');
fprintf(fid_d,' %d\n',ECG_d);
fclose(fid_d);

fid_d=fopen('../../data/Xecg_diff.dat','w');
fprintf(fid_d,' %x\n',ECG_d);
fclose(fid_d);

fid_i=fopen('../../data/ecg_int.dat','w');
fprintf(fid_i,' %d\n',ECG_i);
fclose(fid_d);
