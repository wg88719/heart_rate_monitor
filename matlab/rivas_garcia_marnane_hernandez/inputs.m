clc, clear all, close all
load('../../data/mit-bih/101m.mat') %load data
fs=360;
ECG = val(1,:); %get input vector from loaded data

%[Rpos R ecgd ecgi ecgs] = fixed_rivas(ECG);
[Rpos R ] = fixed_rivas(ECG);

%figure, 
%subplot(411), plot(ECG), axis tight
%title('original ECG')
%subplot(412), plot(ecgd), axis tight
%title('Differentiator output')
%subplot(413), plot(ecgi), axis tight
%title('integrator outout')
%subplot(414), plot(ecgs), axis tight
%title('Squaring output')
%hold on, scatter(Rpos, R)
